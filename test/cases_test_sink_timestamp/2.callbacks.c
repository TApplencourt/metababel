#include <metababel/metababel.h>
#include <stdbool.h>
#include <stdio.h>

static void btx_condition(void *btx_handle, void *usr_data, const char *event_class_name, 
                          bool *matched, int64_t timestamp) {
  *matched = true;
}

static void btx_callback(void *btx_handle, void *usr_data, const char *event_class_name,
                         int64_t timestamp) {
  printf("%ld\n",timestamp);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_matching_callback_sc1(btx_handle, &btx_condition, &btx_callback);
}
