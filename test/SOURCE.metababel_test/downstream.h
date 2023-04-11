#pragma once
#include "component.h"
#include <babeltrace2/babeltrace.h>
#ifdef __cplusplus
extern "C" {
#endif
void btx_downstream_move_messages(
    btx_message_iterator_t *message_iterator_private_data,
    bt_message_array_const messages, uint64_t capacity, uint64_t *count);

void btx_downstream_push_message(
    btx_message_iterator_t *message_iterator_private_data,
    const bt_message *message);

bt_trace_class *
btx_downstream_trace_class_create_rec(bt_self_component *self_component);

bt_trace *btx_downstream_trace_create_rec(bt_trace_class *trace_class);

void btx_push_messages_stream_beginning(
    bt_self_message_iterator *self_message_iterator,
    btx_message_iterator_t *message_iterator_private_data);
void btx_push_messages_stream_end(
    bt_self_message_iterator *self_message_iterator,
    btx_message_iterator_t *message_iterator_private_data);

void btx_push_message_event_2(
    void *btx_handle,
    uint64_t sf_3);
#ifdef __cplusplus
}
#endif
