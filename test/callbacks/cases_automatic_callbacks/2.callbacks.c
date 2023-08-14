#include <metababel/metababel.h>

static void event_callback_1(void *btx_handle, void *usr_data) {
  btx_push_message_event(btx_handle);
}

static void event_callback_2(void *btx_handle, void *usr_data) {
  btx_push_message_event(btx_handle);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event(btx_handle, &event_callback_1);
  btx_register_callbacks_event(btx_handle, &event_callback_2);
}
