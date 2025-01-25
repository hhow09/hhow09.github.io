---
title: Authorization server for mobile applications
description: implementation details of OAuth server for mobile applications 
date: 2023-12-30
tags:
  - oauth
  - system design
layout: layouts/post.njk
---

Notes of working on Authorization server for mobile applications.

## Goal
- Manage user registration and authentication for mobile applications.
- Reduce the development time for application teams.

## Requirement
- Any legitimate user from supported 3rd Identity Provider (IDP) (e.g. Google, Apple) can register/login to application.
- Authorization server should manage the user registration and authentication for multiple applications.
- Authorization server should provide a unified authentication process **for application servers** given different 3rd party identity providers (e.g. google, apple and others... ).
    - Authorization server should works as a **single identity provider** for application servers.
- Authorization server should provide backoffice interface for managing user account and sessions.
- Authorization server should support **refresh token rotation**.

## Related RFCs
- [RFC 6749 OAuth 2.0 Authorization Framework](https://datatracker.ietf.org/doc/html/rfc6749)
- [RFC 8252 OAuth 2.0 for Native Apps](https://datatracker.ietf.org/doc/html/rfc8252)
- [RFC 7662 OAuth 2.0 Token Introspection](https://datatracker.ietf.org/doc/html/rfc7662)

## Terms
### Client [^1]
>  An application making protected resource requests on behalf of the resource owner and with its authorization.  The term "client" does not imply any particular implementation characteristics (e.g., whether the application executes on a server, a desktop, or other devices).

#### native application client [^2]
> A native application is a public client installed and executed on the device used by the resource owner.  Protocol data and credentials are accessible to the resource owner.  It is assumed that any client authentication credentials included in the application can be extracted.  On the other hand, dynamically issued credentials such as access tokens or refresh tokens can receive an acceptable level of protection.  At a minimum, these credentials are protected from hostile servers with which the application may interact.  On some platforms, these credentials might be protected from other applications residing on the same device.

### ID Token [^3]

> The ID Token is a security token that contains Claims about the Authentication of an End-User by an Authorization Server when using a Client, and potentially other requested Claims. The ID Token is represented as a [JSON Web Token (JWT)](https://openid.net/specs/openid-connect-core-1_0.html#JWT) [JWT].

- [Google supports open ID Connect](https://developers.google.com/identity/openid-connect/openid-connect)
- [Android: Sign-in with Google](https://developer.android.com/identity/sign-in/credential-manager-siwg#instantiate-google)
- [Apple Successfully Implements OpenID Connect with Sign In with Apple](https://openid.net/apple-successfully-implements-openid-connect-with-sign-in-with-apple/)

## Design choices
### How to identify the user ?
- The application need to validate the user's legitimacy on 3rd party identity provider.
- The application does NOT need to access the resource from user.
- Given the requirements, **ID Token** is the best choice for the application to identify the user.
    - safer than access token.

### Login flow design
- Mobile client can use SDK e.g. [Android: Sign-in with Google](https://developer.android.com/identity/sign-in/credential-manager-siwg#instantiate-google) obtain `id_token` from IDP.
- After obtaining `id_token`, the mobile client can follow [OAuth2.0: Client Credentials Grant](https://datatracker.ietf.org/doc/html/rfc6749#section-4.4) to request the access of to its own application server (resource server).

## Login Flow
### Participants
- Mobile App (client)

- Application Server (resource server)
    - responsible for business logic
    - responsible for validating `access_token`

- Auth Service
    - responsible for user authentication: validating `id_token`
    - responsible for user authorization: issue `access_token`
    - responsible manage user account and sessions for application server

- 3rd Party Auth Service (e.g. Google, Apple)
    - responsible for user authentication: issue `id_token`

### Flow Chart

```mermaid
sequenceDiagram
    autonumber
    participant App as Mobile App
    participant S as App Server
    participant AS as Auth Service
    participant 3AS as 3rd Party Auth Service (Google|Apple)

    rect rgb(191, 223, 255)
        note over App: native app plugin
        App ->>+ 3AS: 3rd party login and authorization
        3AS -->>- App: id_token
    end

    App ->>+ AS: Login(id_token)
    AS ->>+ 3AS: Validate id_token
    3AS -->>- AS: user info
    Note over AS: Identify the existed account or link to a new account
    Note over AS: Initiate new session for an account
    AS -->>- App: Access Token, Refresh Token

    App ->> S: Request(access_token)
    Note over S: Validate access_token
    Note over S: Handle request
    S -->> App: response
```


### Notes
1.  for step 1 - 2, [Roles](https://datatracker.ietf.org/doc/html/rfc6749#section-1.1) in the context of OAuth 2.0
    - mobile App served as [client](https://datatracker.ietf.org/doc/html/rfc6749#section-1.1)
    - 3rd Party Auth Service (Google, Apple) served as [authorization server](https://datatracker.ietf.org/doc/html/rfc6749#section-1.1)
    - App Server served as [resource server](https://datatracker.ietf.org/doc/html/rfc6749#section-1.1)

1. details flow for step 1 - 2 [^4]
    {% image "./app-authorization.png", "Authorization flow for Installed applications" %}
1.  after step 3, [Roles](https://datatracker.ietf.org/doc/html/rfc6749#section-1.1) in the context of OAuth 2.0
    - mobile App served as [client](https://datatracker.ietf.org/doc/html/rfc6749#section-1.1)
    - **Auth Service served as [authorization server](https://datatracker.ietf.org/doc/html/rfc6749#section-1.1)**
    - App Server served as [resource server](https://datatracker.ietf.org/doc/html/rfc6749#section-1.1)

1. step 7: resource server token validation
> The resource server MUST validate the access token and ensure ... *[RFC 6749 7](https://datatracker.ietf.org/doc/html/rfc6749#section-7)*
1. step 7: how to validate access token ? 
> These include using structured token formats such as JWT or proprietary inter-service communication mechanisms *[RFC 7662](https://datatracker.ietf.org/doc/html/rfc7662#section-1)*

## Refresh Token Rotation
in another post: [OAuth 2.0 - Refresh Token and Rotation](/blog/oauth2-refresh-token)

---
## Tricky Parts
### Client authentication for mobile apps [^5]
> Secrets that are statically included as part of an app distributed to multiple users should not be treated as confidential secrets, as one user may inspect their copy and learn the shared secret.
> Authorization servers that still require a statically included shared secret for native app clients MUST treat the client as a public client

#### Risk: client impersonation
> In short, OAuth client impersonation is when one OAuth client pretends to be another, usually to take advantage of any capabilities that the legitimate client may have that are not granted to other clients.

#### Are there any solutions for client impersonation? [^6]
> For mobile apps, there is more hope. Apple has an API known as “App Attestation”, and Google has a similar API called “Google Play Integrity”. Both APIs work similarly, with a few technical differences. At a high level, both of them involve the application making a request to the operating system to sign some data. Then the app includes that signed string in the call it makes to the developer’s API. The API can validate the signature against the public key from Apple and Google to determine its confidence level that the API request is made from a real version of the mobile app.

## Reference
[^1]: [RFC 6749 1.1](https://datatracker.ietf.org/doc/html/rfc6749#section-1.1)
[^2]: [RFC 6749 2.1](https://datatracker.ietf.org/doc/html/rfc6749#section-2.1)
[^3]: [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html#IDToken)
[^4]: [Google OAuth: Installed applications](https://developers.google.com/identity/protocols/oauth2#installed)
[^5]: [RFC 8252 8.5: Client Authentication](https://datatracker.ietf.org/doc/html/rfc8252#section-8.5)
[^6]: [Okta: The Identity of OAuth Public Clients](https://developer.okta.com/blog/2022/06/01/oauth-public-client-identity#what-is-oauth-client-impersonation)