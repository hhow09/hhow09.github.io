# Cache Control

## Response Header

- `Cache-Control`: The server can return a `Cache-Control` directive to specify how, and for how long, the browser and other intermediate caches should cache the individual response.
- `ETag`: When the browser finds an expired cached response, it can send a small token (usually a hash of the file's contents) to the server to check if the file has changed. If the server returns the same token, then the file is the same, and there's no need to re-download it.
- `Last-Modified`This header serves the same purpose as ETag, but uses a time-based strategy to determine if a resource has changed, as opposed to the content-based strategy of ETag.

![Cache Control](https://web-dev.imgix.net/image/admin/htXr84PI8YR0lhgLPiqZ.png)
//TODO
//TODO

## Reference

- [Prevent unnecessary network requests with the HTTP Cache](https://web.dev/http-cache/#cache-control)
