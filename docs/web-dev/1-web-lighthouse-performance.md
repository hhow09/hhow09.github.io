# Lighthouse Performance

## 前言

如何定義一個好的網頁？[LightHouse](https://web.dev/measure/)下的網頁評分標準有四項：

- Performance
- Best Practices
- SEO
- Accessibility

本次紀錄主要探討 Performance 部分。

## 效能測試工具

- [PageSpeed Insights](https://developers.google.com/speed/pagespeed/insights/)只會測 Performance 相關 issue。

- [GTmetrix](https://gtmetrix.com/)

- [Chrome Devtool Performance](https://medium.com/coding-hot-pot/%E6%AA%A2%E6%B8%AC%E6%95%88%E8%83%BD%E7%9A%84%E5%A5%BD%E5%B9%AB%E6%89%8Bchrome-devtool-performance-2ae96e7c4f69) 可以直接在 Browser 上測。

## 原理

### Critical Rendering Path

#### Download Resource

![Analysis DOM CSS](/img/web-dev/1-web-lighthouse-performance/analysis-dom-css.png "Analysis DOM CSS")

- 第一次往返: 傳輸 html。
- 第二次-第 N 次往返: 傳輸 CSS 和 JS。

#### Rendering Process

![Rendering Process Event](/img/web-dev/1-web-lighthouse-performance/rendering-process-event.png "Rendering Process Event")

- 頁面要等到 DOM 和 CSSOM 都解析完後，才會 render 出畫面。

#### 名詞解釋

- 關鍵資源/禁止轉譯資源：可能禁止網頁初次轉譯的資源。
  - CSS 預設為禁止轉譯(render blocking)，也就是 CSSOM 還未建構完成前，瀏覽器不會進行轉譯。
  - 「禁止轉譯」僅指該資源是否會阻止瀏覽器初次轉譯網頁。無論是否禁止，瀏覽器仍會下載 CSS，只是優先順序較低。
- 關鍵路徑長度：即往返過程數量，或擷取所有關鍵資源所需的總時間。
- 關鍵位元組：實現網頁初次轉譯所需的總位元組數，這是所有關鍵資源的傳輸檔案大小總和。

---

## 優化實作

### 優化方向 - PRPL pattern

- Push (or preload) the most important resources.
- Render the initial route as soon as possible.
- Pre-cache remaining assets.
- Lazy load other routes and non-critical assets.

### CSS 優化

- 定義: CSS 預設為禁止轉譯，也就是 CSSOM 還未建構完成前，瀏覽器不會進行轉譯。
- 效能: 過多的禁止轉譯 CSS 會影響 FCP, TTI 等效能指數。
- 優化:
  - inline/preload critical CSS
  - defer non-critical CSS
    ```html
    <link rel="preload" as="style" href="async_style.css" onload="this.rel='stylesheet'" />
    <noscript><link rel="stylesheet" href="[yourcssfile]" /></noscript>
    ```
  - CSS import 會增加往返次數/影響效能

### JS 優化

- 原則: 若首次載入時**沒有需要 JS 才能顯示的部分**，則 JS 理論上不影響 FCP。
- 過去: JS 若在 DOM 解析完成前執行，會阻擋 DOM 解析，因此基本上放 body 最後。
- 現行: 使用`defer`和`async`延遲載入 JS，可以直接放`header`
- SPA: 首次渲染慢，因為還要等 JS 解析完，但可以從減少 bundle 大小優化，也就是 Code-Splitting。

### Preload

- 原先 Browser 有內建的資源優先等級，使用 preload，更進一步設定載入優先順序
- 可套用對象: CSS/JS/Font
- 使用情境: CSS, 和牽涉到關鍵路徑的 JS 等重要資源
- prelod: 標示資源為高優先順序
- ref: [
  ```html
  <link rel="preload" as="script" href="super-important.js" />
  <link rel="preload" as="style" href="critical.css" />
  <link rel="preload" as="font" crossorigin="anonymous" type="font/woff2" href="myfont.woff2" />
  ```

### 圖片 Lazy-Loading

1. with HTML ([Can I use loading-lazy-attr](https://caniuse.com/loading-lazy-attr))

```html
<img src="my-image.jpg" loading="lazy" />
```

2. with JS (IntersectionObserver)
   - 不讓圖片正常載入
   - 監視圖片元素，判斷它們是否進入到畫面中
   - 元素進入畫面後，再載入圖片
   - 範例 1: [Lazy loading images using IntersectionObserver - example code](https://codepen.io/imagekit_io/pen/BPXQZZ)
   - 範例 2: [Lazy Loading background images in CSS](https://codepen.io/imagekit_io/pen/RBXVrW)

---

## Performance 指標

based on [Lighthouse V6](https://web.dev/lighthouse-whats-new-6.0/)

![Page Loading Key Moment](/img/web-dev/1-web-lighthouse-performance/page_loading_key_moment.png)

### FCP (First Contentful Paint) 首次內容繪製

- 當瀏覽者到達網站之後，首次顯示 DOM 內容需要的時間。
- `FCP = TTFB(Time to First Byte) + Content Load Time + Render Time`
- 優化方法:
  1. 降低 TTFB: Hosting Provider, CDN, cache
  2. 移除阻擋渲染的資源: Inline Critical Resources, Defer Non-Critical Resources, Remove Anything Unused
  3. 將 Critical Path 的 CSS 做 inline
  4. 首次渲染的圖片不要做 Lazy Loading
  5. inline-SVG
  6. 降低 DOM-tree 大小: 僅在需要時創建 node，銷毀不需要的 node，不要用 CSS 隱藏 / 不要過多層的`div`
  7. 確保在字體 loading 完成之前文字仍可見: `font-face`, CDN:`＆display = swap`
  8. 使用 Resource Hint: `prerender` , `preload`, `prefetch`, `preconnect`
  9. 避免 Redirect
  - ref:[10 Proven Ways To Improve First Contentful Paint (FCP) in WordPress](https://wp-rocket.me/blog/improving-first-contentful-paint/)

### SI (Speed Index) 速度指數

- 速度指數會以「網頁可見內容填入速度」計算，也就是以眼睛可以看到的圖像去計算分數。
- 因素: html+CSS
  ```
  Frame[i] = interval time*(1 – visual complete %/100)
  SI score = Frame[1]+...+Frame[n]
  ```
  - ref: [Understanding Speed Index](https://blog.catchpoint.com/2017/04/20/understanding-speed-index/)

### TTI (Time to Interactive) 可互動時間

- 「網頁進入完整互動狀態前」花費的時間，簡單來說網站要全部載入才能開始閱讀、互動。
- 因素: HTML+CSS+圖片+JavaScript

### LCP (Largest Contentful Paint) 最大內容繪製

- 最大的文字、圖片或是影片呈現到眼前所需要的時間。
- 因素: 文字+圖片

### CLS (Cumulative Layout Shift) 累計版面配置轉移

- 測量可見元素在可視區域內的移動情形，當網站讀取過慢，正要點的時候按鈕(物件)忽然跑掉造成點錯位置，越少越好。
- 常見原因:
  - 沒有圖框包圍的圖像
  - 沒有尺寸的廣告或嵌入式 iframe
  - 動態注入的內容

### TBT (Total Blocking Time) 封鎖時間總計

- 當工作長度超過 50 毫秒時，從 FCP 到 TTI 之間，準備時間的時間範圍總計，延遲越久分數越低。
- 因素:FCP、TTI、SI。

### FID (First Input Delay 首次輸入延遲

- 測量互動性的速度，為了提供良好的用戶體驗，網頁的 FID 應當小於 100 毫秒，像是點擊(Click)。
- 無論是點擊連結、影片、圖片，只要點下去反應很慢的，慢到以為網站故障、無作用，就是「首次輸入的延遲」。
  ![SEO V6](/img/web-dev/1-web-lighthouse-performance/SEO-V6.png "SEO V6")

---

## Reference

- [分析關鍵轉譯路徑效能](https://developers.google.com/web/fundamentals/performance/critical-rendering-path/analyzing-crp?hl=zh-tw)
- [禁止轉譯的 CSS](https://developers.google.com/web/fundamentals/performance/critical-rendering-path/render-blocking-css?hl=zh-tw)
- [Apply instant loading with the PRPL pattern](https://web.dev/apply-instant-loading-with-prpl/)
- [[教學] 深入淺出 Preload, Prefetch 和 Preconnect：三種加快網頁載入速度的 Resource Hint 技巧](https://shubo.io/preload-prefetch-preconnect/)
- [10 Proven Ways To Improve First Contentful Paint (FCP) in WordPress](https://wp-rocket.me/blog/improving-first-contentful-paint/)
- [Understanding Speed Index](https://blog.catchpoint.com/2017/04/20/understanding-speed-index/)
- [Web - Timeline of a page load (Page Speed|Page Latency)](https://datacadamia.com/web/browser/page_load)
