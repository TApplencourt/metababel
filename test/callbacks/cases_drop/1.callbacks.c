#include <metababel/metababel.h>

static void usr_event_1_callback(void *btx_handle, void *usr_data) {
  btx_push_message_event_1(btx_handle);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event_1(btx_handle, &usr_event_1_callback);
}
