#include <metababel/metababel.h>
#include <stdbool.h>

void btx_push_usr_messages(void *btx_handle, void *usr_data, btx_source_status_t *status) {
  btx_push_message_sched_switch(btx_handle);
  btx_push_message_rcu_utilization(btx_handle);
  btx_push_message_kmem_kfree(btx_handle);
  btx_push_message_event_1(btx_handle);
  btx_push_message_event_2(btx_handle);
  btx_push_message_event_3(btx_handle);
  *status = BTX_SOURCE_END;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_push_usr_messages(btx_handle, &btx_push_usr_messages);
}
