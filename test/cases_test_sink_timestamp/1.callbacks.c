#include <metababel/metababel.h>
#include <stdio.h>

static void event_1_0(void *btx_handle, void *usr_data, int64_t timestamp) {
  printf("%ld\n",timestamp);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event_1(btx_handle, &event_1_0);
}
