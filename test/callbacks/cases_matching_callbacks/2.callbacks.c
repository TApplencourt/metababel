#include <metababel/metababel.h>

static void usr_foo_callback(void *btx_handle, void *usr_data, const char *event_class_name) {
  btx_push_message_event(btx_handle, "usr_foo_callback");
}

static void usr_bar_callback(void *btx_handle, void *usr_data, const char *event_class_name) {
  btx_push_message_event(btx_handle, "usr_bar_callback");
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_usr_foo_event(btx_handle, &usr_foo_callback);
  btx_register_callbacks_usr_bar_event(btx_handle, &usr_bar_callback);
}
