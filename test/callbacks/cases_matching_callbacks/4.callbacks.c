#include <metababel/metababel.h>

static void usr_callback(
  void *btx_handle, void *usr_data, int64_t _timestamp) {
  btx_push_message_event(btx_handle, _timestamp);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_usr_event(btx_handle, &usr_callback);
}
