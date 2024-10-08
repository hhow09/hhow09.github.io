---
title: OAuth 2.0 - Refresh Token and Rotation
description: Notes about refresh token and rotation details
date: 2023-12-08
tags:
  - oauth
  - system design
layout: layouts/post.njk
---

## Specification
1. Refresh tokens are credentials used to obtain access tokens. [^1]
    - (1) when current access token expires.
    - (2) to obtain additional access tokens with identical or narrower scope.
2. Issuing a refresh token is optional at the discretion of the authorization server. [^1]
3. Refresh tokens MUST be kept confidential in transit and storage, and shared only among the authorization server and the client to whom the refresh tokens were issued. [^2]
4. The authorization server MUST maintain the binding between a refresh token and the client to whom it was issued. [^2]
5. Refresh tokens MUST only be transmitted using TLS [^2]
6. The authorization server MUST verify the binding between the refresh token and client identity. [^2]
7. When client authentication is not possible, the authorization server SHOULD deploy other means to detect refresh token abuse. [^2] 
    - e.g. [Refresh Token Rotation](#refresh-token-rotation)
9. If a refresh token is compromised and subsequently used by both the attacker and the legitimate client, one of them will present an  invalidated refresh token, which will inform the authorization server of the breach. [^2]

10. The authorization server MUST ensure that refresh tokens cannot be generated, modified, or guessed to produce valid refresh tokens by unauthorized parties. [^2]
    - cannot be modified: signing
    - cannot be guessed: encryption

### Other Specifications
1. OAuth 2.0 Token Revocation [^3]
2. Refresh Token Expiration
    - The refresh token has not been used for six months. [^4]
    - LinkedIn offers programmatic refresh tokens that are valid for a fixed length of time. [^5]

## Refresh Access Token
### Why
- access token usually issued for a limited time.
- In the scenario of an expiring access token, your application has two alternatives:
    - Ask the users of your application to re-authenticate each time an access token expires.
    - The authorization server automatically issues a new access token once it expires.

### How to Refreshing an Access Token ?
#### Client Request
```
     POST /token HTTP/1.1
     Host: server.example.com
     Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
     Content-Type: application/x-www-form-urlencoded
     grant_type=refresh_token&refresh_token=tGzv3JOkF0XG5Qx2TlKWIA
```

#### Auth Server [^6]
1. MUST authenticate the client if client authentication is included 
2. MUST validate the refresh token. 
3. IF valid and authorized, the authorization server issues an access token 
4. The authorization server MAY issue a new refresh token, in which case the client MUST discard the old refresh token and replace it with the new refresh token.
5. The authorization server MAY revoke the old refresh token after issuing a new refresh token to the client.
6. If a new refresh token is issued, the refresh token scope MUST be identical to that of the refresh token included by the client in the request.


#### Flow [^7]

```
  +--------+                                           +---------------+
  |        |--(A)------- Authorization Grant --------->|               |
  |        |                                           |               |
  |        |<-(B)----------- Access Token -------------|               |
  |        |               & Refresh Token             |               |
  |        |                                           |               |
  |        |                            +----------+   |               |
  |        |--(C)---- Access Token ---->|          |   |               |
  |        |                            |          |   |               |
  |        |<-(D)- Protected Resource --| Resource |   | Authorization |
  | Client |                            |  Server  |   |     Server    |
  |        |--(E)---- Access Token ---->|          |   |               |
  |        |                            |          |   |               |
  |        |<-(F)- Invalid Token Error -|          |   |               |
  |        |                            +----------+   |               |
  |        |                                           |               |
  |        |--(G)----------- Refresh Token ----------->|               |
  |        |                                           |               |
  |        |<-(H)----------- Access Token -------------|               |
  +--------+           & Optional Refresh Token        +---------------+

               Figure 2: Refreshing an Expired Access Token
```

## Refresh Token Rotation
1. Refresh token rotation is intended to automatically detect and prevent attempts to use the same refresh token in parallel from different apps/devices. This happens if a token gets stolen from the client and is subsequently used by both the attacker and the legitimate client. [^8]
2. The basic idea is to change the refresh token value with every refresh request in order to detect attempts to obtain access tokens using old refresh tokens. [^8]
3. It's a way to prevent token reuse according to [Specification 7](#specification)

### Implementatino Notes
1. In accessing data storage layer, (1) New Refresh Token and (2) Invalidate Refresh Token should be atomic.
2. [Okta: Refresh token rotation](https://developer.okta.com/docs/guides/refresh-tokens/main/#refresh-token-rotation)
3. [Auth0: Refresh Token Rotation](https://auth0.com/docs/secure/tokens/refresh-tokens/refresh-token-rotation)

## Refresh token reuse detection
1. If a previously used refresh token is used again with the token request, the authorization server automatically detects the attempted reuse of the refresh token. [^9]
2. As a result, Okta immediately invalidates the most recently issued refresh token and all access tokens issued since the user authenticated. This protects your application from token compromise and replay attacks.[^9]
    - Since the authorization server cannot determine whether the attacker or the legitimate client is trying to access, in case of such an access attempt the valid refresh token and the access authorization associated with it are both revoked. [^8]

### Reuse Scenario [^10]
{% image "./refresh-token-reuse-1.png", "Scenario 1: Refresh Token Reuse" %}

{% image "./refresh-token-reuse-2.png", "Scenario 2: Refresh Token Reuse" %}
> In these scenarios, the reuse of a refresh token triggers all kinds of alarms with the authorization server. Refresh token reuse likely means that a second party is trying to use a stolen refresh token. In response to this reuse, the authorization server immediately revokes the reused refresh token, along with all descendant tokens. Concretely, all refresh tokens that have ever been derived from the reused refresh token become invalid.


### Issue: Client Can Retry v.s. Replay attack
1. Token reuse detection can sometimes impact the user experience. For example, when users with poor network connections access apps, new tokens issued by Okta might not reach the client app. As a result, the client might want to reuse the refresh token to get new tokens. [^11]
2. According to [Specification 8](#specification), Refresh token reuse detection should be implemented for preventing [replay attack](https://auth0.com/docs/secure/security-guidance/prevent-threats#replay-attacks).

3. Without enforcing sender-constraint, it’s impossible for the authorization server to know which actor is legitimate or malicious in the event of a replay attack. [^14]
    - If retry is allowed, it means somehow security is sacrificed in some degree.
4. Related discussion: [ory/hydra: Refresh tokens need a grace period to deal with network errors and similar issues #1831](https://github.com/ory/hydra/issues/1831)

#### Solution from Okta: Grace period [^11]
- Okta offers a grace period when you configure refresh token rotation. After the refresh token is rotated, the previous token remains valid for the configured amount of time to allow clients to get the new token.
- The default number of seconds for the Grace period for token rotation is set to **30** seconds. You can change the value to any number from 0-60 seconds. After the refresh token is rotated, the previous token remains valid for this amount of time to allow clients to get the new token.

#### Solution from Auth0: Grace period [^12]
- Enter Reuse Interval (in seconds) for the refresh token to account for leeway time between request and response before triggering automatic reuse detection. This interval helps to avoid concurrency issues when exchanging the rotating refresh token multiple times within a given timeframe. During the leeway window the breach detection features don't apply and a new rotating refresh token is issued. Only the previous token can be reused; if the second-to-last one is exchanged, breach detection will be triggered.

#### Solution from ory/fosite: Grace period [^15]
```go
// https://github.com/ory/fosite/blob/869a37ce486cb0ca921449319e1048004b2f1bd8/handler/oauth2/flow_refresh.go#L144
func (c *RefreshTokenGrantHandler) PopulateTokenEndpointResponse(ctx context.Context, requester fosite.AccessRequester, responder fosite.AccessResponder) (err error) {
    // ...
    if err := c.TokenRevocationStorage.RevokeRefreshTokenMaybeGracePeriod(ctx, ts.GetID(), signature); err != nil {
        return err
    }
    // ...
}
```
- PR on storage implimentation: [feat: Refresh token expiration window #2827](https://github.com/ory/hydra/pull/2827)

#### Solution 2: Revokaion-On-Use [^13]
1. Allow client retry with same refresh token
    - Keep track of (1) one parent toke (RT1) and (2) a pool of child tokens.
    - parent token means the latest token's 
    - child token means the retry-results of same parent. But **we don't know if they actually successfully recieved by client**.
    - parent token (RT1) could generate multiple child refresh tokens and access tokens in pairs ((RT2, AT2), (RT2-1, AT2-1)...). Keep track of them.
2. Invalidate other refresh tokens AFTER (1) one of sibling refresh token or (2) the corresponding `access_token` once used.
    - Once `AT2-1` is used, (1) sibling (RT2, AT2), (RT2-2, AT2)... should be revoked
        - because it ensures client already received one of the retries.
    - Once `RT2-1` is used (in next refresh), (1) sibling (RT2, AT2), (RT2-2, AT2)... should be revoked (2) (RT3, AT3) should be generated (3) `RT2-1` should considered used and become parent.

3. Concurrent token READ (token introspection) and WRITE (refresh token) should be handled carefully.

## Open Source OAuth Server
- [https://github.com/ory/fosite.git](https://github.com/ory/fosite.git)
- [https://github.com/supertokens/supertokens-core](https://github.com/supertokens/supertokens-core)
- [https://github.com/keycloak/keycloak/blob/main/services/src/main/java/org/keycloak/jose/jws/DefaultTokenManager.java](https://github.com/keycloak/keycloak/blob/main/services/src/main/java/org/keycloak/jose/jws/DefaultTokenManager.java)

## Reference
[^1]: [RFC 6749 1.5: Refresh Token](https://datatracker.ietf.org/doc/html/rfc6749#section-1.5)
[^2]: [RFC 6749 10.4: Refresh Tokens](https://datatracker.ietf.org/doc/html/rfc6749#section-10.4)
[^3]: [RFC 7009: OAuth 2.0 Token Revocation](https://datatracker.ietf.org/doc/html/rfc7009)
[^4]: [Google OAuth](https://developers.google.com/identity/protocols/oauth2?hl=en#5.-refresh-the-access-token,-if-necessary)
[^5]: [Google Refresh Tokens with OAuth 2.0](https://learn.microsoft.com/en-us/linkedin/shared/authentication/programmatic-refresh-tokens)
[^6]: [RFC 6749 6: Refreshing an Access Token](https://datatracker.ietf.org/doc/html/rfc6749#section-6)
[^7]: [RFC 6749 1.5: Refresh Token](https://datatracker.ietf.org/doc/html/rfc6749#section-1.5)
[^8]: [RFC 6819 5.2.2.3: Refresh Token Rotation](https://datatracker.ietf.org/doc/html/rfc6819#section-5.2.2.3)
[^9]: [Okta: Refresh token reuse detection](https://developer.okta.com/docs/guides/refresh-tokens/main/#set-up-your-application)
[^10]: [A Critical Analysis of Refresh Token Rotation in Single-page Applications](https://www.pingidentity.com/en/resources/blog/post/refresh-token-rotation-spa.html)
[^11]: [Okta: Grace period for token rotation](https://developer.okta.com/docs/guides/refresh-tokens/main/#grace-period-for-token-rotation)
[^12]: [Auth0: Configure Refresh Token Rotation](https://auth0.com/docs/secure/tokens/refresh-tokens/configure-refresh-token-rotation)
[^13]: [How to protect against losing `refresh_token` response?](https://devforum.zoom.us/t/how-to-protect-against-losing-refresh-token-response/10375/1)
[^14]: [Auth0: Refresh Token Rotation](https://auth0.com/docs/secure/tokens/refresh-tokens/refresh-token-rotation)
[^15]: [ory/fosite](https://github.com/ory/fosite)
