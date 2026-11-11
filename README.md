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


## Routing messages

Besides the event callbacks, which get the decoded fields of the events of their class, two
*additional callbacks* get the `bt_message` itself. They are enabled at generation time:

| `--enable-additional-callbacks NAMES` | component | callback |
|---|---|---|
| `upstream_event_fallback` | FILTER, SINK | an upstream event no callback is registered for |
| `downstream_message` | SOURCE, FILTER | every message the component sends downstream |

Both are `(void *btx_handle, void *usr_data, const bt_message *message)`, registered with
`btx_register_callback_<name>`. There is one callback per name (hence `callback`, singular,
unlike the `btx_register_callbacks_` of the events): registering another one replaces it.
A registered additional callback always runs; without one, the default applies (like the `default`
of a `switch`). The message is borrowed: the callback sends it on with a push function, or does
nothing and it is dropped. Metababel puts the reference after the callback; to keep the message
after the callback returns, take a reference (`bt_message_get_ref`) and put it when done.

- Upstream event fallback: the upstream events no callback is registered for (whether or not their
  class is in the upstream model). Messages that are not events are always forwarded by a filter and
  dropped by a sink.
  - FILTER: the callback sends it downstream with `btx_push_message`, or drops it. Without a
    callback, `--upstream-event-default MODE` applies: `passthrough` (default) forwards the event,
    `drop` puts it.
  - SINK: without a callback, the event is dropped.
- Downstream message: every message the component sends downstream (its own events, its stream
  messages, and what a filter forwards). The callback puts it in the output queue with
  `btx_direct_push_message`, or drops it. Without a callback, the message goes to the output queue.

`--upstream-event-default` applies to a FILTER only. With an additional callback enabled, the
upstream model is optional (the callbacks see every event).

### Sending messages downstream

`btx_handle` is the one every callback receives (the component).

| function | sends | through the downstream message callback | exists with |
|---|---|---|---|
| `btx_push_message_<name>(btx_handle, ...)` | a new event of the downstream model | yes | always |
| `btx_push_message(btx_handle, message)` | the message the fallback callback borrows | yes | `--enable-additional-callbacks upstream_event_fallback` (FILTER) |
| `btx_direct_push_message(btx_handle, message)` | the message the downstream callback borrows, to the output queue | no | `--enable-additional-callbacks downstream_message` |

In the downstream message callback, use `btx_direct_push_message` to let a message through:
`btx_push_message` would give it back to the same callback, forever. What the callback creates with
`btx_push_message_<name>` comes back to it, like any message sent downstream.

How a filter routes an upstream message:

```
upstream message
├─ not an event (stream/packet beginning/end, ...) → forwarded
└─ event: is a callback registered for its class?
   ├─ yes → the callbacks run with the decoded fields, then the message is put
   │        (to send something downstream, they create events with btx_push_message_<name> → forwarded)
   └─ no  → is an upstream event fallback callback registered?
            ├─ yes → the callback: btx_push_message → forwarded, or nothing → put
            └─ no  → --upstream-event-default
                     ├─ passthrough → forwarded
                     └─ drop        → put

the filter's own stream beginning/end messages → forwarded

forwarded → is a downstream message callback registered?
            ├─ yes → the callback: btx_direct_push_message → output queue, or nothing → put
            └─ no  → output queue
```

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
