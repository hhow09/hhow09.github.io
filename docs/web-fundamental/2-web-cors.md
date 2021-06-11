# CORS

Cross-Origin Resource Sharing

## 基礎

- Same Origin 的限制比 Cookie 限制嚴格，基本上只有**網址前面完全相同**，才會算 same origin。
- CORS 是 browser 基於安全性考量而做的限制，非 browser (ex. `Postman`) 則不會遇到。
- 在`<image>`, `<script>` 載入資源，因為 response 會直接印在 html 上，Javascript 無法讀取到，所以可以載入 Cross Origin 的資源。
- `Access-Control-Allow-Origin` **只能加一個網域** 或 \* (全部)
- 解決方法 1: 若對後端沒有掌控權，可以自架 proxy server

## 簡單請求(simple request)

- 來自: 符合以下兩個條件的 request
  1. Request method is: `HEAD`, `GET`, `POST`
  2. Content-Type of `POST` is: `text/plain`, `multipart/form-data`, `application/x-www-form-urlencoded`
- 成功條件: 後端只要加上適當的 `Access-Control-Allow-Origin` header 即可成功。

```javascript
res.header("Access-Control-Allow-Origin", VALID_ORIGIN);
```

## 非簡單請求(not-so-simple request)

- 來自: `簡單請求`以外的情況。
- 會有兩筆 request: 正式 request 之前，會多一次 `Preflight Request`。
- 成功條件: 見 Preflight Request

```javascript
res.header("Access-Control-Allow-Origin", VALID_ORIGIN);
res.header("Access-Control-Allow-Headers", "content-type");
```

### Preflight Request

- 目的: 為了避免陳年的後端`收到預期外的請求`，瀏覽器先詢問伺服器，當前網頁所在的域名是否在伺服器的許可名單之中，以及可以使用哪些 HTTP 動詞和頭資訊欄位。
- 成功條件: 後端需要設定

  1. `Access-Control-Allow-Origin` header 需列出允許的 origin 或 `*`。
  2. `Access-Control-Allow-Headers` header 需列出允許哪些請求的 headers。最常見是 `Content-Type`，如果有其他發送的自訂 header ，也須列在其中。

- 用 Javascript 處理圖片會遇到[Allowing cross-origin use of images and canvas](https://developer.mozilla.org/en-US/docs/Web/HTML/CORS_enabled_image)問題
- 如果 preflight 沒有通過，是不會發出正式的 request

## 非簡單請求 + 帶 Cookie

- 成功條件:
  後端需要設定

  1. `Access-Control-Allow-Origin` header 需要明確指定，不能為`*`
  2. `Access-Control-Allow-Headers` header 需列出允許哪些請求的 headers。
  3. `Access-Control-Allow-Credentials`,header 須為 true

  前端需要設定

  1. fetch 加上 `credentials: include`

```javascript
res.header("Access-Control-Allow-Origin", VALID_ORIGIN); // 明確指定
res.header("Access-Control-Allow-Credentials", true);
res.header("Access-Control-Allow-Headers", "content-type, X-App-Version");
```

## Extras

1. 如前端需要拿到自定義 header，後端就需要帶上 `Access-Control-Expose-Headers: "CUSTOM_HEADER"`
2. `GET`、`HEAD` 以及 `POST` 以外的 HTTP method 發送請求的話，後端的 preflight response header 必須有 `Access-Control-Allow-Methods` 並且指定合法的 method，`preflight` 才會通過，瀏覽器才會把真正的 request 發送出去。
3. 需要快取的話 `Access-Control-Max-Age`

### Reference

- [CORS 完全手冊（一）：為什麼會發生 CORS 錯誤？](https://blog.huli.tw/2021/02/19/cors-guide-1/)
