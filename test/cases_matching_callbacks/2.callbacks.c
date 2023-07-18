#include <assert.h>
#include <metababel/metababel.h>
#include <stdbool.h>
#include <stdio.h>

static void btx_matching_callback(
  void *btx_handle, void *usr_data,int64_t _timestamp, const char *cf_1, uint64_t pf_1) {
  btx_push_message_event_1(btx_handle,_timestamp,cf_1,pf_1);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_foo(btx_handle, &btx_matching_callback);
}
