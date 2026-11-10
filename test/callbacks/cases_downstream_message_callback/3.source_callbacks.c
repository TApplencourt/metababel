#include <babeltrace2/babeltrace.h>
#include <metababel/metababel.h>
#include <stdlib.h>

static void btx_initialize_usr_data(void **usr_data) { *usr_data = calloc(1, sizeof(int)); }

static void btx_finalize_usr_data(void *usr_data) { free(usr_data); }

static void btx_push_usr_messages(void *btx_handle, void *usr_data, btx_source_status_t *status) {
  btx_push_message_event(btx_handle, 1);
  btx_push_message_event(btx_handle, 2);
  btx_push_message_event(btx_handle, 3);
  *status = BTX_SOURCE_END;
}

/* A source too: drop the second event, push everything else. */
static void downstream_message_callback(void *btx_handle, void *usr_data,
                                        const bt_message *message) {
  if (bt_message_get_type(message) == BT_MESSAGE_TYPE_EVENT && ++*(int *)usr_data == 2)
    bt_message_put_ref(message);
  else
    btx_push_message(btx_handle, message);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_component(btx_handle, &btx_initialize_usr_data);
  btx_register_callbacks_finalize_component(btx_handle, &btx_finalize_usr_data);
  btx_register_callbacks_push_usr_messages(btx_handle, &btx_push_usr_messages);
  btx_register_callbacks_downstream_message(btx_handle, &downstream_message_callback);
}
