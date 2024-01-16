<img width="384" alt="METABABEL" src="https://user-images.githubusercontent.com/6524907/217338770-ab69a6c8-f0fa-4e00-9b8f-bf5d2192d0bd.png">

# What symbols to provide?

## Filter & Sink

Link with a object file who export the symbol `btx_register_usr_callbacks(void *)`.

The implementation of `btx_register_usr_callbacks` should conssist of calls to `btx_register_callbacks_#{stream_class_name}_#{event_class_name}(btx_handle, &callbacks)`.

## Source:

Link with a object file who export the symbol `btx_push_usr_messages(struct xprof_common_data *common_data)`.

# Function Provided

## Source & Filter
	
In the callbacks, and in the `btx_push_usr_messages`, you have access to `btx_push_message_{stream_class_name}_#{event_class_name}(struct xprof_common_data *common_data, ...)`.


# Source Description

## State Machine

```mermaid
stateDiagram-v2
    [*] --> BTX_SOURCE_STATE_INITIALIZING
    BTX_SOURCE_STATE_INITIALIZING --> BTX_SOURCE_STATE_PROCESSING
    BTX_SOURCE_STATE_PROCESSING --> BTX_SOURCE_STATE_FINALIZING
    BTX_SOURCE_STATE_FINALIZING --> BTX_FILTER_STATE_FINISHED
    BTX_FILTER_STATE_FINISHED --> [*]
```

# Filter Description

## State Machine

```mermaid
stateDiagram-v2
    [*] --> BTX_FILTER_STATE_INITIALIZING
    BTX_FILTER_STATE_INITIALIZING --> BTX_FILTER_PROCESSING
    state BTX_FILTER_PROCESSING {
        [*] --> BTX_FILTER_PROCESSING_STATE_READING
        [*] --> BTX_FILTER_PROCESSING_STATE_SENDING
	BTX_FILTER_PROCESSING_STATE_SENDING --> BTX_FILTER_PROCESSING_STATE_READING
    	BTX_FILTER_PROCESSING_STATE_READING --> BTX_FILTER_PROCESSING_STATE_SENDING
	BTX_FILTER_PROCESSING_STATE_READING --> BTX_FILTER_PROCESSING_STATE_FINISHED
	BTX_FILTER_PROCESSING_STATE_FINISHED --> [*]
    }
    BTX_FILTER_PROCESSING --> BTX_FILTER_STATE_FINALIZING
    BTX_FILTER_STATE_FINALIZING --> BTX_FILTER_STATE_FINISHED
    BTX_FILTER_STATE_FINISHED --> [*]
```

# Sink Description

At finalization we will call the `btx_user_finalization(struct xprof_common_data *common_data)`

# Callbacks Registration and Calling order
 
```
0 register_callback
1 call_initialize_component # Cannot Push
2 call_read_params
3   stream_begin
4       call_initialize_processing # Can Push
5           call_callbacks
5       call_finalize_processing # Can Push
6   stream_end
7 call_finalize_component # Cannot push
```
