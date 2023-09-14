#include <metababel/metababel.h>

static void usr_event_callback(void *btx_handle, void *usr_data, const char *event_class_name, const char *entry_1,  int64_t entry_2) {}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_usr_event(btx_handle, &usr_event_callback);
}
