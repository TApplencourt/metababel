#include <babeltrace2/babeltrace.h>
#include <metababel/metababel.h>

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  *usr_data = calloc(1, sizeof(int));
}

void btx_finalize_usr_data(void *btx_handle, void *usr_data) { free(usr_data); }

static void event_callback(void *btx_handle, void *usr_data,
                           int64_t timestamp) {
  btx_push_message_event(btx_handle, timestamp);
}

static void on_push_callback(void *btx_handle, void *usr_data,
                             const bt_message *message) {
  // Just forward the first message
  if (bt_message_get_type(message) == BT_MESSAGE_TYPE_EVENT)
    *(int *)(usr_data) += 1;

  if (*(int *)(usr_data) == 1 ||
      bt_message_get_type(message) != BT_MESSAGE_TYPE_EVENT)
    btx_push_message(btx_handle, message);
  else
    bt_message_put_ref(message);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_component(btx_handle,
                                              &btx_initialize_usr_data);
  btx_register_callbacks_finalize_component(btx_handle, &btx_finalize_usr_data);
  btx_register_callbacks_event(btx_handle, &event_callback);
  btx_register_on_push_callback(btx_handle, &on_push_callback);
}
