#include <metababel/metababel.h>

static void usr_foo_event_callback(void *btx_handle, void *usr_data, const char *cf_1, uint64_t pf_1) {}
static void usr_bar_event_callback(void *btx_handle, void *usr_data, const char *cf_1, uint64_t pf_1) {}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_foo(btx_handle, &usr_foo_event_callback);
  btx_register_callbacks_bar(btx_handle, &usr_bar_event_callback);
}
