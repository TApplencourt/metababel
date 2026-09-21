#include <metababel/metababel.h>

void btx_push_usr_messages(void *btx_handle, void *usr_data,
                           btx_source_status_t *status) {
  uint8_t bytes[] = { 0xde, 0xad, 0xbe, 0xef, 0x42 };
  btx_push_message_event(btx_handle, 5, bytes);
  *status = BTX_SOURCE_END;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_push_usr_messages(btx_handle, &btx_push_usr_messages);
}
