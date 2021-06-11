# HTTP Methods

### GET

- idempotent
- pass data only in `param`
- `SAFE`
- Cache: cache-able
- remain in the browser history
- has length restrictions

### POST

- non-idempotent
- pass the data in `body`
- not `SAFE`
- Cache: not `cache-able`, unless the response includes appropriate Cache-Control or Expires header fields.
