#include <babeltrace2/babeltrace.h>
#include <metababel/metababel.h>
#include <unordered_map>

typedef std::unordered_map<const bt_stream *, const bt_message *> StreamToMessage_t;

static void btx_initialize_usr_data(void **usr_data) { *usr_data = new StreamToMessage_t{}; }

static void btx_finalize_usr_data(void *usr_data) { delete ((StreamToMessage_t *)(usr_data)); }

static void on_downstream_message_callback(void *btx_handle, void *usr_data,
                                           const bt_message *message) {

  auto *h = (StreamToMessage_t *)usr_data;
  switch (bt_message_get_type(message)) {
  // Just forward the first message
  case (BT_MESSAGE_TYPE_STREAM_BEGINNING): {
    const bt_stream *stream = bt_message_stream_beginning_borrow_stream_const(message);
    h->insert({stream, message});
    break;
  }
  case (BT_MESSAGE_TYPE_EVENT): {
    // If required Pop and Push stream_begin message associated with the stream of the current
    // message
    const bt_event *event = bt_message_event_borrow_event_const(message);
    const bt_stream *stream = bt_event_borrow_stream_const(event);
    auto it = h->find(stream);
    if (it != h->end()) {
      btx_push_message(btx_handle, it->second);
      h->erase(it);
    }
    btx_push_message(btx_handle, message);
    break;
  }
  case (BT_MESSAGE_TYPE_STREAM_END): {
    const bt_stream *stream = bt_message_stream_end_borrow_stream_const(message);
    auto it = h->find(stream);
    // Only send stream_end message if begin have been sent, if not drop
    if (it == h->end()) {
      btx_push_message(btx_handle, message);
    } else {
      bt_message_put_ref(message);
      bt_message_put_ref(it->second);
      h->erase(it);
    }
    break;
  }
  default:
    bt_message_put_ref(message);
  }
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_component(btx_handle, &btx_initialize_usr_data);
  btx_register_callbacks_finalize_component(btx_handle, &btx_finalize_usr_data);
  btx_register_on_downstream_message_callback(btx_handle, &on_downstream_message_callback);
}
