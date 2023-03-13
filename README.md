<img width="384" alt="METABABEL" src="https://user-images.githubusercontent.com/6524907/217338770-ab69a6c8-f0fa-4e00-9b8f-bf5d2192d0bd.png">

# What symbols to provide?

## Filter & Sink

Link with a object file who export the symbol `btx_usr_register_callbacks(btx_name_to_dispatcher_t**)`.

The implementation of `btx_usr_register_callbacks` should conssist of calls to `btx_register_callbacks_#{stream_class_name}_#{event_class_name}(name_to_dispatcher, &callbacks)`.

## Source:

Link with a object file who export the symbol `btx_push_usr_messages(struct xprof_common_data *common_data)`.

# Function Provided

## Source & Filter
	
In the callbacks, and in the `btx_push_usr_messages`, you have access to `btx_push_message_{stream_class_name}_#{event_class_name}(struct xprof_common_data *common_data, ...)`.


# Source Description

At initialization, we push messages to the downstream queue. 

1. `btx_push_messages_stream_beginning`
2. `btx_push_usr_messages`
3. `btx_push_messages_stream_end`

```mermaid
graph TD
    M[MessageIteratorNext]  --> MTP[Down Stream Queue Empty?]
    MTP -- Yes --> D?[BT_MESSAGE_ITERATOR_CLASS_NEXT_METHOD_STATUS_END]
    MTP -- No --> PM[Pop Messages, BT_MESSAGE_ITERATOR_CLASS_NEXT_METHOD_STATUS_OK]--> DS[/DownStreamMessages\]
```

# Filter Description

```mermaid
graph TD
    UM[\UpstreamMessages/] --> M[MessageIteratorNext] 
    M --> MTP[Down Stream Queue Empty?]
    MTP -- Yes --> D?[Dispatcher?]
    D? -- Yes --> D[Dispatcher]
    D? -- No --> PUS[Push UpstreamStream Message]
    D --> Callbacks
    Callbacks --> CPD[Create and Push DownStream Messages]
    MTP -- No --> PM[Pop Messages]--> DS[/DownStreamMessages\]
```

## State Machine

```mermaid
stateDiagram-v2
    [*] --> BTX_FILTER_PROCESSING
    state BTX_FILTER_PROCESSING {
        [*] --> BTX_FILTER_PROCESSING_STATE_READING
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

```mermaid
graph TD
    UM[\UpstreamMessages/] --> M[MessageIteratorNext] 
    M --> MTP[Down Stream Queue Empty?]
    MTP -- Yes --> D?[Dispatcher?]
    D? -- Yes --> D[Dispatcher]
    D? -- No --> Discarded
    D --> Callbacks
```

At finalization we will call the 
`btx_user_finalization(struct xprof_common_data *common_data)`


