#include <metababel/metababel.h>

static void usr_foo_event_callback(void *btx_handle, void *usr_data, uint64_t pf_1, const char *cf_1) {
  btx_push_message_event(btx_handle,cf_1,pf_1,BT_TRUE);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_foo(btx_handle, &usr_foo_event_callback);
}
