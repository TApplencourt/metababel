#include <metababel/metababel.h>

static void usr_event_callback(void *btx_handle, void *usr_data, int64_t entry_2, const char *entry_1) {}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_usr_event(btx_handle, &usr_event_callback);
}
