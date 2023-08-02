#include <metababel/metababel.h>

void event_callback(void *btx_handle, void *usr_data, uint64_t pf_1, uint64_t pf_2, uint32_t pf_3, int64_t pf_4, int64_t pf_5, int32_t pf_6 ) {
  btx_push_message_event(pf_1, pf_2, pf_3, pf_4, pf_5, pf_6);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event(btx_handle, &event_callback);
}
