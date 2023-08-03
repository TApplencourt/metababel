#include <metababel/metababel.h>

void event_callback(void *btx_handle, void *usr_data, const char *pf_1, const char *pf_2, const char *pf_3) {
  btx_push_message_event(btx_handle, pf_1, pf_2, pf_3);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event(btx_handle, &event_callback);
}
