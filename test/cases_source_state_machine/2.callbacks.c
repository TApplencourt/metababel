#include <inttypes.h>
#include <metababel/metababel.h>


void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  for (int i = 0; i < 4; ++i) btx_push_message_event_1(btx_handle, i);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_usr_data(btx_handle, &btx_initialize_usr_data);
}