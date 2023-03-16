# Test cases

## Field

1. No common field.
2. No payload field.
3. No common field, no payload (SHOULD FAIL).
4. Common field, payload field.
5. Hundred common field, hundred payload fields, random field types.

## Type string

1. No common field
1.1. Empty string
1.2. 200 length random text

## Type unsigned integer

1. No comman field
1.1. 0
1.2. (2^64) - 1 (SHOULD FAIL)
1.3. (2^64) (SHOULD FAIL)
1.4. -1 (SHOULD FAIL)

## Type bool

1. No comman field
1.1. true
1.2. false
1.3. 0
1.4. 1
1.5. -1
