# TEST CASES

## Source 

* test_cases_stream_classes_models
1. No common field
2. No payload field
3. No common field, no payload (FAIL)
4. Common, Payload fields
5. Hundred Common, Paylad field
6. Babeltrace stream data structure vs model.yaml consistency checking, all types
7. Babeltrace stream data structure vs model.yaml  consistency checking, integers without field_range_value (It should render uint64 or int64 accordingly)

* test_cases_type_bool
1. True
2. False

* test_cases_type_string

1. Empty
2. Large string (264 base 64 characters, including spaces)
3. Nesting pattern.

* test_cases_type_uint

1. uint64 Zero
2. uint64 `(2^64) - 1`, `field_value_range = 64`
3. uint32 `(2^32) - 1`, no `cast_type`, `field_value_range = 32`
