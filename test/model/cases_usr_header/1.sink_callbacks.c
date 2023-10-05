#include <metababel/metababel.h>
#include <assert.h>

static void event_callback(void *btx_handle, void *usr_data, struct MyStruct pf_1) {
  assert(strcmp(pf_1.dummy, "John Doe") == 0);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event(btx_handle, &event_callback);
}
