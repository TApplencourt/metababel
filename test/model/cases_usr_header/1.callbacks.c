#include <metababel/metababel.h>

static void event_callback(void *btx_handle, void *usr_data, usr_string_t pf_1) {}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event(btx_handle, &event_callback);
}
