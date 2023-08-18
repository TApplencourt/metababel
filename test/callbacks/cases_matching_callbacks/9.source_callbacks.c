#include <metababel/metababel.h>
#include <assert.h>

void btx_push_usr_messages(void *btx_handle, void *usr_data, btx_source_status_t *status) {
  bt_trace *trace = ((common_data_t *) btx_handle)->downstream_trace;
  bt_trace_set_environment_entry_status stat_1 = bt_trace_set_environment_entry_string(trace, "entry_1", "dummy value");
  bt_trace_set_environment_entry_status stat_2 = bt_trace_set_environment_entry_integer(trace, "entry_2", -1);
  assert(stat_1 == BT_TRACE_SET_ENVIRONMENT_ENTRY_STATUS_OK);
  assert(stat_2 == BT_TRACE_SET_ENVIRONMENT_ENTRY_STATUS_OK);

  btx_push_message_event(btx_handle);
  *status = BTX_SOURCE_END;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_push_usr_messages(btx_handle, &btx_push_usr_messages);
}
