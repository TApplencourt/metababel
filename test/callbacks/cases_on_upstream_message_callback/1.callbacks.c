#include <babeltrace2/babeltrace.h>
#include <metababel/metababel.h>
#include <stdio.h>

static void btx_initialize_usr_data(void **usr_data) { *usr_data = calloc(1, sizeof(int)); }

static void btx_finalize_usr_data(void *usr_data) {
  printf("on_upstream: %d other messages\n", *(int *)usr_data);
  free(usr_data);
}

static void event_a_callback(void *btx_handle, void *usr_data, uint64_t value) {
  printf("event_a: %lu\n", (unsigned long)value);
}

/* The events no callback handles, and the other messages. */
static void on_upstream_message_callback(void *btx_handle, void *usr_data, const bt_message *message) {
  if (bt_message_get_type(message) == BT_MESSAGE_TYPE_EVENT)
    printf("on_upstream: %s\n",
           bt_event_class_get_name(bt_event_borrow_class_const(bt_message_event_borrow_event_const(message))));
  else
    *(int *)usr_data += 1;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_component(btx_handle, &btx_initialize_usr_data);
  btx_register_callbacks_finalize_component(btx_handle, &btx_finalize_usr_data);
  btx_register_callbacks_event_a(btx_handle, &event_a_callback);
  btx_register_on_upstream_message_callback(btx_handle, &on_upstream_message_callback);
}
