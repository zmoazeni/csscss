## (Unreleased)

* 0 and 0px are now reconciled as redundancies
* Disables color support by default for windows & ruby < 2.0
* Fixes bug where unquoted url(data...) isn't parsed correctly
* Adds support for LESS files

## 1.1.0 - 4/12/2013 ##

* Fixes bug where CLI --no-color wasn't respected
* Added ruby version requirement for >= 1.9
* Added CONTRIBUTORS.md
* Fixes bugs with urls that have dashes in them
* Fixes bugs with urls containing encoded data (usually images)
* Deprecates CSSCSS_DEBUG in favor of --show-parser-errors
* Fixes line/column output during parser errors
* --compass now grabs config.rb by default if it exists
* Adds --compass-with-config that lets users specify a config
* Fixes parser error bug when trying to parse blank files
* Fixes bug where rules from multiple files aren't consolidated
* Adds --no-match-shorthand to allow users to opt out of shorthand matching

## 1.0.0 - 4/7/2013 ##

* Allows the user to specify ignored properties and selectors
* Better parse error messages

## 0.2.1 - 3/28/2013 ##

* Changes coloring to the selectors and declarations
* Fixes bug where some duplicates weren't being combined #1

## 0.2.0 - 3/24/2013 ##

* Colorizes text output.
* Supports scss/sass files.
* Fixes newline output bug when there are no redundancies
* Downloads remote css files if passed a URL
* Fixes bug with double semicolons (blank attributes)

## 0.1.0 - 3/21/2013 ##

* Initial project release.
