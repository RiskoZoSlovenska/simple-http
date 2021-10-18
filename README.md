# simple-http

The goal of this [`coro-http`](https://bilal2453.github.io/coro-docs/docs/coro-http.html) wrapper is simple: to simplify the process of making simple HTTP requests as much as possible. `simple-http` offers [automatic content encoding/decoding](#encoding), [friendlier header declarations](#requestmethod-url-payload-encoding-headers-schema-options) and data verification using [`Schema`](https://github.com/super-agent/schema).

<br>

## Installation

`simple-http` can be installed from [lit](https://luvit.io/lit.html) using
```
lit install RiskoZoSlovenska/simple-http
```

Once installed, it can be required using
```lua
local http = require("simple-http")
```

<br>

## Example

To :
```lua

```

<br>

## Docs

### The `simple-http` module

When you require `simple-http`, you get a table with the following values. You can learn more about each below.

* [`request`](#requestmethod-url-payload-encoding-headers-schema-options)
* [`Encoding`](#encoding)
* [`coroHttp`](https://bilal2453.github.io/coro-docs/docs/coro-http.html)
* [`json`](https://luvit.io/api/json.html)
* [`querystring`](https://luvit.io/api/querystring.html)
* [`schema`](https://github.com/super-agent/schema)

<br>

### Functions

#### `request(method, url, payload, encoding, headers, schema, options)`

|Parameter|Type                    |Optional|Description/Notes|
|:-------:|:----------------------:|:------:|:---:|
|method   |`string`                |❌||
|url      |`string`                |❌||
|payload  |`any`                   |✔️|Must be a table if `encoding` is specified|
|Encoding |`Encoding`              |✔️||
|headers  |`table`                 |✔️||
|schema   |`Schema`                |✔️|A [Schema](https://github.com/super-agent/schema#built-in-types) object to verify the integrity of the data with|
|options  |`RequestOptions/Timeout`|✔️||

*See [`coro-http`'s `request`'s parameters](https://bilal2453.github.io/coro-docs/docs/coro-http.html#request-parameters) for more info.*

<br>

Performs an HTTP(S) request.

If `encoding` is specified, attempts to encode the payload and inserts the `Content-Type` header if it isn't already specified. Otherwise, the payload is simply converted to a string.

The `headers` parameter accepts both the `{{key, value}, ...}` and `{[key] = value, ...}` formats. If both are used, the unordered `[key] = value` pairs are appended to the list of ordered key-value pairs in no particular order.

When the request returns, if it specifies a `Content-Type` header with supported encoding, the data will be automatically decoded into a lua table.

This function never throws an error unless faulty data is passed to it; it always returns a 3-tuple in the format `data`, `res`, `errInfo`. If the request succeeds, `data` will be the (possibly decoded) body, `res` will be the [Response](https://bilal2453.github.io/coro-docs/docs/coro-http.html#request-response) object returned by the request and `errInfo` will be `nil`. Otherwise, if the request fails, `data` will be `nil`, `res` will be an error message and `errInfo` *may* be extra data about why the request failed (for example, if the response returned a faulty body, it will be the body received).


**Returns:** `table|string|nil`, [`Response`]((https://bilal2453.github.io/coro-docs/docs/coro-http.html#request-response))`|string`, `any|nil`

<br>

### Enums

#### `Encoding`

The `Encoding` enum is used to specify the encoding/decoding algorithm used by the [request](#requestmethod-url-payload-encoding-headers-schema-options) function. The function expects the enum value, not the enum name.

|Enumeration|Value                                |Functions used|
|:---------:|:-----------------------------------:|:------------:|
|json       |`"application/json"`                 |[json.encode](https://luvit.io/api/json.html#json_json_encode_value_state) and [json.decode](https://luvit.io/api/json.html#json_json_decode_str_pos_nullval)|
|url        |`"application/x-www-form-urlencoded"`|[querystring.stringify](https://luvit.io/api/querystring.html#querystring_querystring_stringify_obj_sep_eq_options) and [querystring.parse](https://luvit.io/api/querystring.html#querystring_querystring_parse_str_sep_eq_options)|