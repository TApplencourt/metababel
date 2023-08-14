#include <metababel/metababel.h>

// Prevent event 1 to be passed around (downstream)
static void btx_event_1_callback(void *btx_handle, void *usr_data) {}

static void usr_event_2_callback(void *btx_handle, void *usr_data, uint64_t dummy) {
  btx_push_message_event_2(btx_handle,dummy);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event_1(btx_handle, &btx_event_1_callback);
  btx_register_callbacks_usr_event(btx_handle, &usr_event_2_callback);
}
