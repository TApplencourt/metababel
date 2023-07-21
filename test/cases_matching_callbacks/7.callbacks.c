#include <metababel/metababel.h>
#include <assert.h>

static void usr_event_1_callback(void *btx_handle, void *usr_data, uint64_t dummy_1) {
  // The first arguments, dummy_1, that match is unsigned integer. 
  // If we match the second argument, dummy_1, the program will fail 
  // at compile time since it is const char *.
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_foo(btx_handle, &usr_event_1_callback);
}
