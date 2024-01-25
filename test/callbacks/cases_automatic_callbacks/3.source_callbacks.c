#include <metababel/metababel.h>
#include <babeltrace2/babeltrace.h>
#include <assert.h>

void btx_push_usr_messages(void *btx_handle, void *usr_data, btx_source_status_t *status) {
  btx_downstream_set_environment_entry_1(btx_handle, "dummy value");
  btx_downstream_set_environment_entry_2(btx_handle, -1);
  btx_push_message_event(btx_handle);
  *status = BTX_SOURCE_END;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_push_usr_messages(btx_handle, &btx_push_usr_messages);
}
