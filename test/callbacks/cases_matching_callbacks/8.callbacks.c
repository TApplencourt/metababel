#include <metababel/metababel.h>

static void usr_event_callback(void *btx_handle, void *usr_data, const char *event_class_name) {
  btx_push_message_event(btx_handle, event_class_name);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_usr_event(btx_handle, &usr_event_callback);
}
