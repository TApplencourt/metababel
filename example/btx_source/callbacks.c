#include <metababel/metababel.h>


void btx_push_usr_messages(void *btx_handle, void *usr_data, btx_source_status_t *status) {
  int vpid = 1;
  int vtid= 1;
  uint64_t num_entries= 0;
  uint64_t platforms= 1;
  uint64_t num_platform = 2;
  btx_downstream_set_environment_dummy(btx_handle, "roger");
  *status = BTX_SOURCE_END;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_push_usr_messages(btx_handle, &btx_push_usr_messages);
}

