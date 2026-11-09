#include <metababel/metababel.h>

void event_callback(void *btx_handle, void *usr_data, uint64_t length, uint8_t *bytes) {
  btx_push_message_event(btx_handle, length, bytes);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event(btx_handle, &event_callback);
}
