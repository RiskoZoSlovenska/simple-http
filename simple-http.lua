--[[lit-meta
	name = "RiskoZoSlovenska/simple-http"
	version = "1.0.0"
	homepage = "https://github.com/RiskoZoSlovenska/simple-http"
	description = "A basic, high-level wrapper for coro-http."
	tags = {"http", "coro", "wrapper"}
	dependencies = {
		"creationix/coro-http@3.2.3",
		"creationix/schema@1.1.0"
	}
	license = "MIT"
	author = "RiskoZoSlovenska"
]]

local http = require("coro-http")
local json = require("json")
local querystring = require("querystring")
local schema = require("schema")

local string = string
local table = table
local pairs = pairs
local tonumber, tostring = tonumber, tostring
local type = type

local Encoding = {
	json = "application/json",
	url  = "application/x-www-form-urlencoded",
}



local function normalizeHeaders(tbl)
	local normalized = {}

	for i = 1, #tbl do
		normalized[i] = tbl[i]
	end

	for k, v in pairs(tbl) do
		if not normalized[k] then -- Check whether we already assigned this one
			table.insert(normalized, {k, v})
		end
	end

	return normalized
end

local function findHeader(headers, query)
	for i = 1, #headers do
		local header = headers[i]

		if string.lower(header[1]) == query then
			return header, i
		end
	end

	return nil, nil
end

local encoders = {
	[Encoding.json] = json.encode,
	[Encoding.url]  = querystring.stringify,
}
local decoders = {
	[Encoding.json] = json.decode,
	[Encoding.url]  = querystring.parse,
}

--[[--
	Performs an HTTP(S) request.

	If `encoding` is specified, attempts to encode the payload and inserts the
	Content-Type header if it isn't specified. Otherwise, the payload is simply
	converted to a string.

	The `headers` parameter accepts both the {{key, value}, ...} and
	{[key] = value, ...} formats. If both are used, the unordered [key] = value
	pairs are appended to the list of ordered key-value pairs in no particular
	order.

	When the request returns, if it specifies a Content-Type header with
	supported encoding, the data will be automatically decoded into a lua table.

	This function never throws an error, unless faulty data is passed to it; it
	always returns a 3-tuple in the format `data`, `res`, `errInfo`. If the
	request succeeds, `data` will be the (possibly decoded) body, `res` will
	be the Response object returned by the request and `errInfo` will be `nil`.
	Otherwise, if the request fails, `data` will be `nil`, `res` will be an
	error message and `errInfo` *may* be extra data about why the request failed
	(for example, if the response returned a faulty body, it will be the body
	received).

	@param string method
	@param string url
	@param any? payload must be a table if `encoding` is specified
	@param table? headers
	@param Schema? schema a Schema object to verify the integrity of the data with
	@param RequestOptions/Timeout? options

	@return table|string|nil the reply's body, possibly decoded
	@return Response|string if the request succeeded, this will be the Response
	  object returned by coro-http. Otherwise, this will be an error message
	  describing what went wrong error message describing what went wrong, if anything
	@return any|nil if the request fails, this will be additional data that may
      be used to identify the problem
]]
local function request(method, url, payload, encoding, headers, schema, options)
	encoding = encoding or Encoding.json
	headers = headers and normalizeHeaders(headers) or {}

	-- Insert Content-Type header
	if not findHeader(headers, "content-type") then
		table.insert(headers, {"Content-Type", encoding})
	end

	-- Encode payload
	if payload ~= nil and type(payload) ~= "string" then
		payload = (encoders[encoding] or tostring)(payload)
	end


	-- Make request
	local success, res, data = pcall(
		http.request, method, url, headers, payload, options
	)


	-- Handle errors
	if not success then
		return nil, "Sending request failed: " .. tostring(res), nil

	elseif res.code >= 300 then
		return nil, res.code .. ": " .. res.reason, res
	end


	-- Decode response
	do
		local decoding
		local typeHeader = findHeader(res, "content-type")
		if typeHeader then
			decoding = typeHeader[2]:match("^([%a%-]+/[%a%-]+)"):lower()
		end

		local decodeSuccess
		decodeSuccess, data = pcall(decoders[decoding] or tostring, data)

		if not decodeSuccess then
			return nil, "Invalid response data: Failed to decode", data
		end
	end

	-- Typecheck result
	if schema then
		local name, expected, actual = schema("body", data)
		if actual then
			return nil, string.format(
				"Invalid response data: %s: Expected %s, got %s",
				name, expected, actual
			), data
		end
	end

	return data, res, nil
end




return {
	request = request,
	Encoding = Encoding,

	coroHttp = http,
	json = json,
	querystring = querystring,
	schema = schema,
}