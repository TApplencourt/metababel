#include <metababel/metababel.h>

static void event_callback(void *btx_handle, void *usr_data, uint64_t pf_1, int64_t pf_2) {
  btx_push_message_event(btx_handle, pf_1, pf_2);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event(btx_handle, &event_callback);
}
