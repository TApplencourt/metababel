#include <babeltrace2/babeltrace.h>
#include <metababel/metababel.h>
#include <stdio.h>

/* No model: every event comes here. */
static void fallback_callback(void *btx_handle, void *usr_data, const bt_message *message) {
  const bt_event *event = bt_message_event_borrow_event_const(message);
  printf("fallback: %s\n", bt_event_class_get_name(bt_event_borrow_class_const(event)));
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_upstream_event_fallback(btx_handle, &fallback_callback);
}
