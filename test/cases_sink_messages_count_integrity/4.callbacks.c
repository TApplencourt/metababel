#include <metababel/metababel.h>
#include <assert.h>
#include <stdio.h>

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
}

void btx_finalize_usr_data(void *btx_handle, void *usr_data) {
}

static void event_1_0(void *btx_handle, void *usr_data, const char *cf_2) 
{}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event_1(btx_handle, &event_1_0);
}
