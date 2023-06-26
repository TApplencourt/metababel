#include <metababel/metababel.h>

void btx_usr_callback_event_1(void *btx_handle,void *usr_data) {
    btx_push_message_event_1(btx_handle);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event_1(btx_handle,&btx_usr_callback_event_1);
}
