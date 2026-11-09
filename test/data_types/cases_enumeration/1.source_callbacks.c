#include <metababel/metababel.h>
#include <stdint.h>

static void btx_push_usr_messages(void *btx_handle, void *usr_data, btx_source_status_t *status) {
    btx_push_message_event(btx_handle,1, -1);
    btx_push_message_event(btx_handle,23, 0);
    btx_push_message_event(btx_handle,14, 1);
    *status = BTX_SOURCE_END;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_push_usr_messages(btx_handle, &btx_push_usr_messages);
}
