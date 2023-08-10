#include <metababel/metababel.h>

static void event_callback(void *btx_handle, void *usr_data, int64_t timestamp) {
  btx_push_message_event(btx_handle,timestamp);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event(btx_handle, &event_callback);
}
