#include <metababel/metababel.h>

static void usr_event_callback_1(void *btx_handle, void *usr_data, const char * event_class_name, uint64_t pf_1) {
  btx_push_message_event_4(btx_handle, pf_1);
}

static void usr_event_callback_2(void *btx_handle, void *usr_data, const char * event_class_name) {
  btx_push_message_event_4(btx_handle, 0);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_usr_event_1(btx_handle, &usr_event_callback_1);
  btx_register_callbacks_usr_event_2(btx_handle, &usr_event_callback_2);
}
