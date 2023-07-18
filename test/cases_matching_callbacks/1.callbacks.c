#include <metababel/metababel.h>

static void usr_foo_event_callback(void *btx_handle, void *usr_data, uint64_t pf_1, const char *cf_1) {}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_foo(btx_handle, &usr_foo_event_callback);
}
