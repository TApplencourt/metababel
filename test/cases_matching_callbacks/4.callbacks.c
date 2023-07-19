#include <metababel/metababel.h>

static void btx_matching_callback(
  void *btx_handle, void *usr_data, int64_t _timestamp) {
  btx_push_message_event_1(btx_handle, _timestamp);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_foo(btx_handle, &btx_matching_callback);
}
