# TEST CASES

## Source 

* cases_stream_classes_models
1. Common Field *absent*
2. Payload Field *absent*
3. Common Field *absent*, Payload Field *absent*
4. Common Field *present*, Payload Field *present*
5. Hundred Common Field, Hundred Paylad Fields.
6. `model.yaml` -> `sink.text.details` vs `target_btx_details.txt` (written by hand) 
- Expected coherent display of types as defined in `model.yaml` 
- Expected coherent value range as `field_value_range` is *present*. 
7. `model.yaml` -> `sink.text.details` vs `target_btx_details.txt` (written by hand)
- Expected coherent display of types as defined in `model.yaml`.
- Expected coherent default value range, 64, for integers (signed, unsigned) since `field_value_range` is *absent*.
8. `model.yaml` -> `sink.text.details` vs `target_btx_details.txt` (written by hand)
- Expected coherent display of integers as defined in `model.yaml`. 
- Expected coherent default integers value range, 64, since `field_value_range` is *absent* 
- Expected coherent display of integers in different bases 2, 8, 10, and 16 since `preferred_dipslay_base` is *present*.
9. `model.yaml` -> `sink.text.details` vs `target_btx_details.txt` (written by hand)
- Expected coherent display of integers as defined in `model.yaml`
- Expected coherent default integers value ranges, 32, since `field_value_range` is *present* 
- Expected coherent display of integers in different bases 2, 8, 10, and 16 since `preferred_dipslay_base` is *present*.

* cases_type_bool
1. True
2. False

* cases_type_string

1. Empty
2. Large string (264 base 64 characters, including spaces)
3. Nesting pattern

* cases_type_uint

1. uint64 Zero
2. uint64 `(2^64) - 1`, `field_value_range = 64`
3. uint32 `(2^32) - 1`, `cast_type` absent, `field_value_range = 32`

* cases_source_state_machine

1. Test `btx_push_usr_messages` return status (BTX_SOURCE_OK, BTX_SOURCE_END) 


## Sink

* cases_sink_messages_count_integrity

1. Two event classes, one callback registered per event, 100 messages for `event_1`, 100 messages for `event_2`.
- Expected every callback to be called once per incoming event.
2. Two event classes, one callback registered per event, 73 messages for `event_1`, 0 messages for `event_2`.
- Expected every callback to be called once per incoming event.
3. Two event classes, only one callback registred for one event class, 100 messages for `event_1`, 100 messages for `event_2`.
- Expected events with unregistered callbacks to be discarded.
- Expected events with registered callbacks to call the associated callback.
4. User registers the wrong callback.

* cases_sink_stream_classes_model

1. User defined types, cast_type.
