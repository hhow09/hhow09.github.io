# Web Security

## Common Web Applications Attacks

### Cross-Site Scripting (XSS)

#### 常見種類

1. Stored XSS
   藉由 DB 中的 Javascritpt 程式碼攻擊，程式碼可能透過留言板、部落格等輸入方式，將帶有攻擊指令碼的內容存至資料庫中，被當成一般的 HTML 執行。
2. Reflected XSS
   非儲存在 DB 中、前端直接傳送帶有攻擊指令的內容至伺服器。例如以 GET 方式傳送 request 至伺服器時，伺服器未檢查直接回傳資料至網站中。
3. DOM Based XSS
   指網頁上的 JavaScript 在執行過程中，沒有檢查資料使得操作 DOM 的過程植入了攻擊指令。(通常是因為 JS 使用 innerHTML())

#### 如何防範

- 1 和 2 由後端防範：需檢查 HTML 程式碼與使用者輸入的內容，刪除`< script >`等帶有指令的文字。
- 3 由前端防範：避免在 html 內寫 JS/避免使用 innerHTML()來更換網頁內容。
- 3 由後端防範：Content Security Policy 避免開啟 'unsafe-inline'

### SQL Injection

是在輸入的字串之中夾帶 SQL 指令，在設計不良的程式當中忽略了字元檢查，那麼這些夾帶進去的惡意指令就會被資料庫伺服器誤認為是正常的 SQL 指令而執行，因此遭到破壞或是入侵。

#### 常見種類

Authorization Bypass

```
"SELECT * FROM customers WHERE name =' -name- ' AND password = ' -password-'
```

```
input name = 'OR 1=1 --
```

```
"SELECT * FROM customers WHERE name =''OR 1=1
```

#### 如何防範

1. 使用 Regular expression 驗證過濾輸入值與參數中惡意代碼，將輸入值中的單引號置換為雙引號。
2. 限制輸入字元格式並檢查輸入長度。
3. 資料庫設定使用者帳號權限，限制某些管道使用者無法作資料庫存取。

### Distributed Denial of Service (DDoS)

- 使用一台以上的機器向目標發送惡意流量，利用大量網際網路流量淹沒目標伺服器、服務或網路，破壞它們的正常運作。
- 壓力測試工具也可以當作攻擊的工具。

#### 常見種類

- HTTP 洪水攻擊，透過 HTTP GET 和 POST 要求淹沒目標 (ex. High Orbit Ion Cannon (HOIC))
- 利用 UDP 等通訊協定向目標伺服器傳送大量流量(ex.Low Orbit Ion Cannon (LOIC))

#### 如何防禦

- 限速：限制伺服器在特定時間範圍內接受的要求數量
- Web 應用程式防火牆：使用工具來基於一系列規則篩選 Web 流量
- Anycast 網路擴散：在伺服器和傳入流量之間置入一個分散式雲端網路，以提供額外的運算資源來回應要求。

### Clickjacking

#### 攻擊方式

利用網頁的 iFrame 將假造的網頁與正常的網頁載入，在透過 iframe visibility 的屬性設定，將正常網站的網頁(如：銀行網頁)隱藏，讓使用者看到是一個假造的網頁(如：中獎通知)。當使用者輸入帳號密碼時，其實背後是登入實際的網站。駭客因此藉接獲取該銀行的帳號密碼與存取權限。

#### 如何防禦

1. server response 設定 header [X-Frame-Options](https://developer.mozilla.org/zh-TW/docs/Web/HTTP/Headers/X-Frame-Options): SAMEORIGIN / DENY / ALLOW-FROM 來指示文件是否能夠載入 `<frame>`

```
header("X-Frame-Options: SAMEORIGIN");
```

2. server response 設定 header [CSP: frame-ancestors](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/frame-ancestors)

```
Content-Security-Policy: frame-ancestors 'none';
Content-Security-Policy: frame-ancestors 'self' https://www.example.org;
```

#### `X-Frame-Options` v.s. `CSP: frame-ancestors`

> The major difference is that many user agents implement SAMEORIGIN such that it only matches against the top-level document’s location. This directive checks each ancestor.

### CSRF

#### 攻擊方式

假設使用者曾經登入過 example.com 並取得 Cookie，當使用者瀏覽惡意網站 evil.com 時，網站中的 JavaScript 可以對 example.com/pay?amount=1000 發出 POST Request，瀏覽器會自動帶上 example.com 的 Cookie。

#### 防禦方式

1. server 端檢查 Referer 是否為合法 domain

```javascript
const referer = request.headers.referer;
```

2. server 端每次請求生成 CSRF token，並回傳給前端，並驗證每次的 submit，不合 token 的並無法

```javascript
<form action="https://example.com/pay" method="POST">
  <input type="hidden" name="amount" value="1000" />
  <input type="hidden" name="csrftoken" value="someRandomToken" />
  <button type="submit" />
</form>
```

3. SameSite: server 端 cookie header 設定 SameSite，可以使用 Strict 或 Lax 將 Cookie 限制為同一站點請求。
   [SameSite cookies explained](https://web.dev/samesite-cookies-explained/)
