---
title: Protecting Replay Attack
description: protecting Replay Attack
date: 2024-12-22
tags:
  - web security
layout: layouts/post.njk
---
## Replay Attack
> An attack in which the Attacker is able to replay previously captured messages (between a legitimate Claimant and a Verifier) to masquerade as that Claimant to the Verifier or vice versa.

## Protection Approaches
1. IP rate limiting (extra cost)
    - [Google Cloud Armor](https://cloud.google.com/armor/docs/rate-limiting-overview)
1. Enterprise solution (extra cost)
    - [AWS WAF Bot Control](https://aws.amazon.com/tw/waf/features/bot-control/)
    - Recaptcha
1. ~~API key~~ (not safe for public client)
1. nonce (with authentication)

## Simple solution without extra cost: Cryptographic nonce
> Nonce in cryptography means “number once,” and this arbitrary number is only used one time in a cryptographic communication. 

> The nonce helps to prove that the message received was sent by the intended sender and was not intercepted and resent by a bad actor.

{% image "./Nonce-cnonce-uml.png", "Nonce Auth" %}

Typical client-server communication during a nonce-based authentication process including both a server nonce and a client nonce.

### How to choose a nonce 
1. Timestamp
    - client use timestamp as nonce in the request
    - server should verify the timestamp within a certain range
    - **beware of client time skew**
        - user could change the device time, therefore we could use **timestamp returned from server**.

2. random number
    - client generates a random number as nonce
    - server checks the nonce is not used before
    - cons: **need to store nonce in server** for some time (e.g. in cache)

### Is nonce enough?
using nonce without **encryption** or **authentication** is easy to be guessed by attacker.

### Encryption / Authentication
- either way is fine
- for authentication, [HMAC](https://www.okta.com/identity-101/hmac/) is a good choice
- for encryption, [asymmetric encryption](https://en.wikipedia.org/wiki/Public-key_cryptography) is a good choice **for public client**.

## Solution I used
1. client has public key from server
1. client receive **timestamp** from server as nonce
1. client encrypt the nonce with public key and send to server
1. server decrypt the nonce with private key and verify the timestamp within a certain range.

## Reference
- [Reddit: How to prevent the public REST API endpoints from bot attacks? ](https://www.reddit.com/r/ExperiencedDevs/comments/100iumt/how_to_prevent_the_public_rest_api_endpoints_from/)
- [What Is a Cryptographic Nonce? Definition and Meaning](https://www.okta.com/identity-101/nonce/)
- [How do you prevent replay attacks when using HMAC for authentication?](https://www.linkedin.com/advice/0/how-do-you-prevent-replay-attacks-when-using-hmac-authentication)