# Test cases

## Field

1. No common field.
2. No payload field.
3. No common field, no payload.
4. Common field, payload field.
5. Hundred common field, hundred payload fields, random field types: should fail at compile, should fail at run.
- This also should fail at generation, because the invalid YAML?

## Type string

1. No common field
* Empty string
* 200 length random text

## Type unsigned integer

1. No comman field
* 0
* (2^64) - 1
* (2^64)
* -1

## Type bool

1. No comman field
* true
* false
* 0
* 1
* -1
