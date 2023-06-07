#include <assert.h>
#include <metababel/metababel.h>

static void event_1_0(void *btx_handle, void *usr_data, int64_t timestamp) {
  btx_push_message_event_1(btx_handle,timestamp);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event_1(btx_handle, &event_1_0);
}
