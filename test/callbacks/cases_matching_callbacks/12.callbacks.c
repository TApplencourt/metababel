#include <metababel/metababel.h>
#include <assert.h>

static void event_set_2(void *btx_handle, void *usr_data, const char * event_class_name, const char * pf_1) {
  assert(strcmp(event_class_name,"event_1") == 0);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event_set_2(btx_handle, &event_set_2);
}
