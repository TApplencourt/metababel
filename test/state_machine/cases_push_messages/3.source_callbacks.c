#include <metababel/metababel.h>

void btx_finalize_usr_data(void *btx_handle, void *usr_data) {
  for (int i = 0; i < 4; ++i) btx_push_message_event(btx_handle, i);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_finalize_usr_data(btx_handle, &btx_finalize_usr_data);
}
