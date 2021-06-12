# Web Authentication

## Intro

- HTTP request is **stateless**.

## Terms

### Token

### OAuth

---

## Session Based Authentication

- 為解決 http 是`stateless`的特性之下，儲存 user 紀錄。
- Cookie: 在瀏覽器內儲存資料，原本儲存使用者資料，但因為容易被修改/暴露，則改存 Session ID。
- Session: 負責紀錄在 server 端上的使用者訊息，會在一個用戶完成身分認證後，存下所需的用戶資料，接著產生一組對應的 ID，存入 cookie 後傳回用戶端。

## Token Based Authentication: JWT? (JSON Web Tokens)

![jwt-diagram](/img/web-dev/6-web-auth/jwt-diagram.png)

- 用途: 一般被用來在 身份提供者 和 服務提供者 間傳遞被 認證 的用戶身份訊息，以便於從資源伺服器獲取資源。
  - 一次性驗證
  - 跨伺服器登入
- 內容:

  - header: 存放 token 型別與加密方式，經過 base64 編碼。
  - payload: 存放需要傳遞的訊息(ex. iss: 發行人, exp: 到期日, sub: 主題...)，經過 base64 編碼。
  - signature: 存放加密過後的內容。由 header (base64)+payload (base64)+secret 組成。

  ```
  HMACSHA256(base64UrlEncode(header) + "." + base64UrlEncode(payload), 'secret')
  ```

## Reference

- [不要用 JWT 替代 session 管理（上）：全面了解 Token,JWT,OAuth,SAML,SSO](https://zhuanlan.zhihu.com/p/38942172)
