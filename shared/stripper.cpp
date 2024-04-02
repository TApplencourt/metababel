#include <babeltrace2/babeltrace.h>
#include <metababel/metababel.h>
#include <unordered_map>

typedef std::unordered_map<const bt_stream *, const bt_message *> StreamToMessage_t;

struct StreamToMessages_s {
  StreamToMessage_t stream_beginning;
  StreamToMessage_t packet_beginning;
};
typedef struct StreamToMessages_s StreamToMessages_t;

static void btx_initialize_usr_data(void **usr_data) { *usr_data = new StreamToMessages_t{}; }

static void btx_finalize_usr_data(void *usr_data) { delete ((StreamToMessages_t *)(usr_data)); }

static void push_associated_beginnings(void *btx_handle, StreamToMessages_t *h,
                                              const bt_stream *stream) {

  auto it_stream = h->stream_beginning.find(stream);
  if (it_stream != h->stream_beginning.end()) {
    btx_push_message(btx_handle, it_stream->second);
    h->stream_beginning.erase(it_stream);

    auto it_packet = h->packet_beginning.find(stream);
    if (it_packet != h->packet_beginning.end()) {
      btx_push_message(btx_handle, it_packet->second);
      h->packet_beginning.erase(it_packet);
    }
  }
}

static void push_or_drop_message(void *btx_handle, StreamToMessage_t &stm, const bt_stream *stream,
                                 const bt_message *message) {
  auto it = stm.find(stream);
  if (it == stm.end()) {
    btx_push_message(btx_handle, message);
  } else {
    bt_message_put_ref(message);
    bt_message_put_ref(it->second);
    stm.erase(it);
  }
}

static void on_downstream_message_callback(void *btx_handle, void *usr_data,
                                           const bt_message *message) {

  auto *h = (StreamToMessages_t *)usr_data;
  switch (bt_message_get_type(message)) {
  // Save begin
  case (BT_MESSAGE_TYPE_STREAM_BEGINNING): {
    const bt_stream *stream = bt_message_stream_beginning_borrow_stream_const(message);
    h->stream_beginning.insert({stream, message});
    break;
  }
  case (BT_MESSAGE_TYPE_PACKET_BEGINNING): {
    const bt_packet *packet = bt_message_packet_beginning_borrow_packet_const(message);
    const bt_stream *stream = bt_packet_borrow_stream_const(packet);
    h->packet_beginning.insert({stream, message});
    break;
  }
  // Push Event and associated beginnings
  case (BT_MESSAGE_TYPE_EVENT): {
    // If required Pop and Push stream_begin message associated with the stream
    // of the current message
    const bt_event *event = bt_message_event_borrow_event_const(message);
    const bt_stream *stream = bt_event_borrow_stream_const(event);
    push_associated_beginnings(btx_handle, h, stream);
    btx_push_message(btx_handle, message);
    break;
  }
  case (BT_MESSAGE_TYPE_PACKET_END): {
    const bt_packet *packet = bt_message_packet_end_borrow_packet_const(message);
    const bt_stream *stream = bt_packet_borrow_stream_const(packet);
    push_or_drop_message(btx_handle, h->packet_beginning, stream, message);
    break;
  }
  case (BT_MESSAGE_TYPE_STREAM_END): {
    const bt_stream *stream = bt_message_stream_end_borrow_stream_const(message);
    push_or_drop_message(btx_handle, h->stream_beginning, stream, message);
    break;
  }
  default:
    btx_push_message(btx_handle, message);
  }
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_component(btx_handle, &btx_initialize_usr_data);
  btx_register_callbacks_finalize_component(btx_handle, &btx_finalize_usr_data);
  btx_register_on_downstream_message_callback(btx_handle, &on_downstream_message_callback);
}
