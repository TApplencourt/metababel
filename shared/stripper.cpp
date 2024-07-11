#include <babeltrace2/babeltrace.h>
#include <metababel/metababel.h>
#include <string>
#include <unordered_map>

typedef std::unordered_map<const bt_stream *, const bt_message *> StreamToMessage_t;
typedef std::unordered_map<const bt_packet *, const bt_message *> PacketToMessage_t;

struct StreamToMessages_s {
  StreamToMessage_t stream_beginning;
  PacketToMessage_t packet_beginning;
  std::string filter_prefix;
};

typedef struct StreamToMessages_s StreamToMessages_t;

static void btx_initialize_usr_data(void **usr_data) { *usr_data = new StreamToMessages_t{}; }

static void btx_finalize_usr_data(void *usr_data) { delete ((StreamToMessages_t *)(usr_data)); }

static void btx_read_params(void *usr_data, btx_params_t *usr_params) {

  auto *data = (StreamToMessages_t *)usr_data;
  data->filter_prefix = std::string{usr_params->filter_prefix};
}

static void push_associated_beginnings(void *btx_handle, StreamToMessages_t *h,
                                       const bt_message *message) {

  const bt_event *event = bt_message_event_borrow_event_const(message);
  const bt_stream *stream = bt_event_borrow_stream_const(event);

  auto it_stream = h->stream_beginning.find(stream);
  if (it_stream != h->stream_beginning.end()) {
    btx_push_message(btx_handle, it_stream->second);
    h->stream_beginning.erase(it_stream);
  }

  if (bt_stream_class_supports_packets(bt_stream_borrow_class_const(stream))) {
    const auto packet = bt_event_borrow_packet_const(event);
    auto it_packet = h->packet_beginning.find(packet);
    if (it_packet != h->packet_beginning.end()) {
      btx_push_message(btx_handle, it_packet->second);
      h->packet_beginning.erase(it_packet);
    }
  }
}

template <typename T>
static void push_or_drop_message(void *btx_handle,
                                 std::unordered_map<const T *, const bt_message *> &stm,
                                 const T *key, const bt_message *message) {
  auto it = stm.find(key);
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
  // Save begins
  case (BT_MESSAGE_TYPE_STREAM_BEGINNING): {
    const bt_stream *stream = bt_message_stream_beginning_borrow_stream_const(message);
    h->stream_beginning.insert({stream, message});
    break;
  }
  case (BT_MESSAGE_TYPE_PACKET_BEGINNING): {
    const bt_packet *packet = bt_message_packet_beginning_borrow_packet_const(message);
    h->packet_beginning.insert({packet, message});
    break;
  }
  // Push event and associated beginnings
  case (BT_MESSAGE_TYPE_EVENT): {
    if (h->filter_prefix.empty()) {
      push_associated_beginnings(btx_handle, h, message);
      btx_push_message(btx_handle, message);
      break;
    }

    const bt_event *event = bt_message_event_borrow_event_const(message);
    const bt_event_class *event_class = bt_event_borrow_class_const(event);
    const char *class_name = bt_event_class_get_name(event_class);
    if (strncmp(h->filter_prefix.data(), class_name, h->filter_prefix.size()) == 0) {
      push_associated_beginnings(btx_handle, h, message);
      btx_push_message(btx_handle, message);
      break;
    }

    bt_message_put_ref(message);
    break;
  }
  // Drop or push ends
  case (BT_MESSAGE_TYPE_PACKET_END): {
    const bt_packet *packet = bt_message_packet_end_borrow_packet_const(message);
    push_or_drop_message(btx_handle, h->packet_beginning, packet, message);
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
  btx_register_callbacks_read_params(btx_handle, &btx_read_params);
  btx_register_on_downstream_message_callback(btx_handle, &on_downstream_message_callback);
}
