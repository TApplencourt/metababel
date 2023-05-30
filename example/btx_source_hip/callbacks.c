#include <metababel/metababel.h>
#include <stdbool.h>

void btx_push_usr_messages(void *btx_handle, void *usr_data, btx_source_status_t *status) {

  btx_push_message_lttng_ust_hip_hipCreateChannelDesc_entry(btx_handle,0,0,0);
  btx_push_message_lttng_ust_hip_hipCreateChannelDesc_exit(btx_handle,1,0,0);
  btx_push_message_lttng_ust_hip_hipCreateChannelDesc_entry(btx_handle,2,1,0);
  btx_push_message_lttng_ust_hip_hipCreateChannelDesc_exit(btx_handle,3,1,0);

  *status = BTX_SOURCE_END;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_push_usr_messages(btx_handle, &btx_push_usr_messages);
}