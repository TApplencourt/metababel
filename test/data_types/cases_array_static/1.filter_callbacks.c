#include <metababel/metababel.h>

void event_callback(void *btx_handle, void *usr_data, int64_t *entries) {
  btx_push_message_event(btx_handle, entries);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event(btx_handle, &event_callback);
}
