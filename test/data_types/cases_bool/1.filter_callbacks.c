#include <metababel/metababel.h>

void event_callback(void *btx_handle, void *usr_data, bt_bool pf_1, bt_bool pf_2) {
  btx_push_message_event(btx_handle, pf_1, pf_2);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event(btx_handle, &event_callback);
}
