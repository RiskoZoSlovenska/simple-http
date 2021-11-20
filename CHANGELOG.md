# Changelog

## 1.1.0
* Added the changelog
* Better errors
	* Added the `ErrorInfo` structure
	* Added the `FailReason` enum
	* The `errInfo` return is now defined instead of "possibly being some related value"
	* Passing in an invalid payload will now no longer throw an error; it will be handled correctly
* Fixed the `encoding` parameter incorrectly defaulting to `json`
* Minor fixes to the README

## 1.0.0
Initial implementation