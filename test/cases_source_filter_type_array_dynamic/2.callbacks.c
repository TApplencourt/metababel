#include <assert.h>
#include <metababel/metababel.h>

void array_dynamic(void *btx_handle, void *usr_data, uint64_t length, uint64_t dummy, int64_t* entries) {
   btx_push_message_array_dynamic(btx_handle, length, dummy, entries);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_array_dynamic(btx_handle, &array_dynamic);
}
