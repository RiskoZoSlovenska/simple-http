# simple-http

The goal of this [`coro-http`](https://bilal2453.github.io/coro-docs/docs/coro-http.html) wrapper is simple: to simplify the process of making simple HTTP requests as much as possible. `simple-http` offers [automatic content encoding/decoding](#encoding), [friendlier header declarations](#requestmethod-url-payload-encoding-headers-schema-options) and data verification using [`Schema`](https://github.com/super-agent/schema).


## Installation

`simple-http` can be installed from [lit](https://luvit.io/lit.html) using
```
lit install RiskoZoSlovenska/simple-http
```

Once installed, it can be required using
```lua
local http = require("simple-http")
```


## Examples

The [two examples on the `coro-http` docs page](https://bilal2453.github.io/coro-docs/docs/coro-http.html#request-examples) can be rewritten using `simple-http` as such:

```lua
local page, res = http.request("GET", "https://www.google.com")
if not page then
	print("Could not fetch www.google.com successfully: " .. res); return
end
print("Received Google main page HTML: " .. page)
```

```lua
local webhookUrl = "https://discord.com/api/webhooks/{ID}/{TOKEN}" -- Your webhook URL here
local success, res = http.request(
	"POST", webhookUrl,
	{
		content = "Hello There!\nThis is an example for a POST request using simple-http!"
	},
	http.Encoding.json, -- simple-http will automatically encode the payload
	nil, -- The Content-Type and Content-Length headers are autofilled
	nil,
	5000
)
-- Did it send it successfully or error?
if not success then
   print("Failed to send webhook: " .. res); return
end
print("Webhook sent successfully!")
```

To illustrate using schemas, the following code could be used to request the definition of "hello" from https://dictionaryapi.dev/ :
```lua
local endpoint = "https://api.dictionaryapi.dev/api/v2/entries/en/hello" -- Get the definition of "hello" from 

local schema = http.schema
local Record, Array, Optional, String = schema.Record, schema.Array, schema.Optional, schema.String
local RecordArray = function(...) return Array(Record(...)) end
local responseSchema = RecordArray{
	word = String,
	phonetics = Optional(RecordArray{
		text = String,
	}),
	meanings = RecordArray{
		partOfSpeech = String,
		definitions = RecordArray{
			definition = String,
			example  = Optional(String),
			synonyms = Optional(Array(String)),
			antonyms = Optional(Array(String)),
		},
	},
}

local definition, res = http.request("GET", endpoint, nil, nil, nil, responseSchema)

if not definition then
   print("Failed to get definition: " .. res); return
end
print("Definition of \"hello\": " .. definition[1].meanings[1].definitions[1].definition) -- Response is automatically decoded to a Lua table
```


## Docs

### The `simple-http` module

When you require `simple-http`, you get a table with the following values. You can learn more about each below.

* [`request`](#requestmethod-url-payload-encoding-headers-schema-options)
* [`Encoding`](#encoding)
* [`coroHttp`](https://bilal2453.github.io/coro-docs/docs/coro-http.html)
* [`json`](https://luvit.io/api/json.html)
* [`querystring`](https://luvit.io/api/querystring.html)
* [`schema`](https://github.com/super-agent/schema)


### Functions

#### `request(method, url, payload, encoding, headers, schema, options)`

|Parameter|Type                    |Optional|Description|
|:-------:|:----------------------:|:------:|:---:|
|method   |`string`                |❌||
|url      |`string`                |❌||
|payload  |`any`                   |✔️||
|encoding |[`Encoding`](#encoding) |✔️||
|headers  |`table`                 |✔️||
|schema   |`Schema`                |✔️|A [Schema](https://github.com/super-agent/schema#built-in-types) object to verify the integrity of the data with|
|options  |`RequestOptions/Timeout`|✔️||

*See [`coro-http.request`'s parameters](https://bilal2453.github.io/coro-docs/docs/coro-http.html#request-parameters) for more info.*


Performs an HTTP(S) request. Just like `coro-http.request`, this function has to be called from a coroutine.

If `encoding` is specified, attempts to encode the payload and inserts the `Content-Type` header if it isn't already specified. Otherwise, the payload is simply converted to a string.

The `headers` parameter accepts both the `{{key, value}, ...}` and `{[key] = value, ...}` formats. If both are used, the unordered `[key] = value` pairs are appended to the list of ordered key-value pairs in no particular order.

When the request returns, if it specifies a `Content-Type` header with supported encoding, the data will be automatically decoded into a Lua table.

This function never throws an error unless faulty data is passed to it; it always returns a 3-tuple in the format `data`, `res`, `errInfo`. If the request succeeds, `data` will be the (possibly decoded) body, `res` will be the [Response](https://bilal2453.github.io/coro-docs/docs/coro-http.html#request-response) object returned by the request and `errInfo` will be `nil`. Otherwise, if the request fails, `data` will be `nil`, `res` will be an error message and `errInfo` *may* be extra data about why the request failed (for example, if the response returned a faulty body, it will be the body received).

This function will fail (return `nil` as the first argument) if:
* `coro-http.request` throws an error, or
* the response status code is `300` or greater, or
* the decoder function throws an error while decoding the response body, or
* a schema check is provided and the body fails it.

**Returns:** `table|string|nil`, `Response|string`, `any|nil`


### Enums

#### `Encoding`

The `Encoding` enum is used to specify the encoding/decoding algorithm used by the [request](#requestmethod-url-payload-encoding-headers-schema-options) function. The function expects the enum value, not the enum name.

|Enumeration|Value                                |Functions used|
|:---------:|:-----------------------------------:|:------------:|
|json     |`application/json`                 |[json.encode](https://luvit.io/api/json.html#json_json_encode_value_state) and [json.decode](https://luvit.io/api/json.html#json_json_decode_str_pos_nullval)|
|url      |`application/x-www-form-urlencoded`|[querystring.stringify](https://luvit.io/api/querystring.html#querystring_querystring_stringify_obj_sep_eq_options) and [querystring.parse](https://luvit.io/api/querystring.html#querystring_querystring_parse_str_sep_eq_options)|
