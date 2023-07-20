#include <metababel/metababel.h>

static void usr_foo_callback(void *btx_handle, void *usr_data) {
  btx_push_message_event_1(btx_handle,"usr_foo_callback");
}

static void usr_bar_callback(void *btx_handle, void *usr_data) {
  btx_push_message_event_1(btx_handle,"usr_bar_callback");
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_foo(btx_handle, &usr_foo_callback);
  btx_register_callbacks_bar(btx_handle, &usr_bar_callback);
}
