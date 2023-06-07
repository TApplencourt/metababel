#include <assert.h>
#include <metababel/metababel.h>
#include <stdbool.h>

static void btx_condition(void *btx_handle, void *usr_data, const char *event_class_name, 
                          bool *matched, int64_t timestamp) {
  *matched = true;
}

static void btx_callback(void *btx_handle, void *usr_data, const char *event_class_name,
                         int64_t timestamp) {
  btx_push_message_event_1(btx_handle,timestamp);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_matching_callback_sc1(btx_handle, &btx_condition, &btx_callback);
}
