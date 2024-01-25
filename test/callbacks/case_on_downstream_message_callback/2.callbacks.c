#include <assert.h>
#include <metababel/metababel.h>

static void btx_initialize_usr_data(void **usr_data) {
  *usr_data = calloc(1, sizeof(int));
}

static void btx_finalize_usr_data(void *usr_data) {
  // 2 begin/end * 2 (one for source, one for filter)
  // + 3 message sent by the source and forwarded by the filter
  // = 7 messages totals
  assert(*(int *)(usr_data) == 7);
  free(usr_data);
}
static void on_downstream_message_callback(void *btx_handle, void *usr_data,
                                           const bt_message *message) {
  *(int *)(usr_data) += 1;
  btx_push_message(btx_handle, message);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_component(btx_handle,
                                              &btx_initialize_usr_data);
  btx_register_callbacks_finalize_component(btx_handle, &btx_finalize_usr_data);
  btx_register_on_downstream_message_callback(btx_handle,
                                              &on_downstream_message_callback);
}
