#include <metababel/metababel.h>
#include <assert.h>

static void event_set_1_callback(void *btx_handle, void *usr_data, const char * event_class_name) {
  assert(strcmp(event_class_name,"event_1") == 0);
}

static void event_set_2_callback(void *btx_handle, void *usr_data, const char * event_class_name, uint64_t pf_1) {
  assert(strcmp(event_class_name,"event_1") == 0);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event_set_1(btx_handle, &event_set_1_callback);
  btx_register_callbacks_event_set_2(btx_handle, &event_set_2_callback);
}
