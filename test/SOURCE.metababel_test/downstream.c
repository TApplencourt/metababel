#include "component.h"
#include "utlist.h"
#include <babeltrace2/babeltrace.h>
#include <stdlib.h>

void btx_downstream_move_messages(
    btx_message_iterator_t *message_iterator_private_data,
    bt_message_array_const messages, uint64_t capacity, uint64_t *count) {

  // Set count to min(capacity, common_data->queue.size())
  // Count time, pop the head of the queue and put it in messages
  for (*count = 0; *count < capacity && message_iterator_private_data->queue;
       (*count)++) {
    struct el *elt = message_iterator_private_data->queue;
    messages[*count] = elt->message;
    DL_DELETE(message_iterator_private_data->queue, elt);
    // Put it back to the bool of chain for reuse
    DL_APPEND(message_iterator_private_data->pool, elt);
  }
}

void btx_downstream_push_message(
    btx_message_iterator_t *message_iterator_private_data,
    const bt_message *message) {

  struct el *elt;
  if (message_iterator_private_data->pool) {
    elt = message_iterator_private_data->pool;
    DL_DELETE(message_iterator_private_data->pool, elt);
  } else {
    elt = (struct el *)malloc(sizeof *elt);
  }
  elt->message = message;
  DL_APPEND(message_iterator_private_data->queue, elt);
}

bt_trace_class *
btx_downstream_trace_class_create_rec(bt_self_component *self_component) {
  bt_trace_class *trace_class = bt_trace_class_create(self_component);
  {
    bt_stream_class *trace_class_sc_0;
    trace_class_sc_0 = bt_stream_class_create(trace_class);
    bt_stream_class_set_name(trace_class_sc_0, "sc1");
    {
      bt_event_class *trace_class_sc_0_ec_0;
      trace_class_sc_0_ec_0 = bt_event_class_create(trace_class_sc_0);
      bt_event_class_set_name(trace_class_sc_0_ec_0, "event_2");
      {
        bt_field_class *trace_class_sc_0_ec_0_p_fc;
        trace_class_sc_0_ec_0_p_fc = bt_field_class_structure_create(trace_class);
        {
          bt_field_class *trace_class_sc_0_ec_0_p_fc_m_0;
          trace_class_sc_0_ec_0_p_fc_m_0 = bt_field_class_integer_unsigned_create(trace_class);
          bt_field_class_integer_set_field_value_range(trace_class_sc_0_ec_0_p_fc_m_0, 64);
          bt_field_class_structure_append_member(trace_class_sc_0_ec_0_p_fc, "sf_3", trace_class_sc_0_ec_0_p_fc_m_0);
        }
        bt_event_class_set_payload_field_class(trace_class_sc_0_ec_0, trace_class_sc_0_ec_0_p_fc);
      }
    }
  }

  return trace_class;
}

bt_trace *btx_downstream_trace_create_rec(bt_trace_class *trace_class) {
  bt_trace *trace = bt_trace_create(trace_class);
  {
    bt_stream_class *stream_class =
        bt_trace_class_borrow_stream_class_by_index(trace_class, 0);
    bt_stream_create(stream_class, trace);
  }
  return trace;
}

void btx_push_messages_stream_beginning(
    bt_self_message_iterator *self_message_iterator,
    btx_message_iterator_t *message_iterator_private_data) {

  bt_trace *trace =
      message_iterator_private_data->common_data->downstream_trace;
  {
    bt_stream *stream = bt_trace_borrow_stream_by_index(trace, 0);
    bt_message *message =
        bt_message_stream_beginning_create(self_message_iterator, stream);
    btx_downstream_push_message(message_iterator_private_data, message);
  }
}

void btx_push_messages_stream_end(
    bt_self_message_iterator *self_message_iterator,
    btx_message_iterator_t *message_iterator_private_data) {

  bt_trace *trace =
      message_iterator_private_data->common_data->downstream_trace;
  {
    bt_stream *stream = bt_trace_borrow_stream_by_index(trace, 0);
    bt_message *message =
        bt_message_stream_end_create(self_message_iterator, stream);
    btx_downstream_push_message(message_iterator_private_data, message);
  }
}

static void btx_set_message_event_2(
    bt_event *event,
    uint64_t sf_3) {
  {
    bt_field *event_p_f = bt_event_borrow_payload_field(event);
    {
      bt_field *event_p_f_m_0 = bt_field_structure_borrow_member_field_by_index(event_p_f, 0);
      bt_field_integer_unsigned_set_value(event_p_f_m_0, sf_3);
    }
  }

}

void btx_push_message_event_2(
    void *btx_handle,
    uint64_t sf_3) {

  common_data_t *common_data = (common_data_t *)btx_handle;

  bt_stream *stream = bt_trace_borrow_stream_by_index(
      common_data->downstream_trace, 0);
  bt_stream_class *stream_class = bt_stream_borrow_class(stream);
  bt_event_class *event_class = bt_stream_class_borrow_event_class_by_index(
      stream_class, 0);

  bt_message *message = bt_message_event_create(
      common_data->self_message_iterator, event_class, stream);
  bt_event *downstream_event = bt_message_event_borrow_event(message);

  btx_set_message_event_2(
      downstream_event, sf_3);

  btx_message_iterator_t *message_iterator_private_data =
      bt_self_message_iterator_get_data(common_data->self_message_iterator);
  btx_downstream_push_message(message_iterator_private_data, message);
}
