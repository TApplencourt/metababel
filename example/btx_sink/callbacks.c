#include <metababel/metababel.h>
#include <stdio.h>

void btx_getplatformids_callbacks(void *btx_handle, void *common_data, int vpid, int vtid,
                                  uint64_t num_entries, uint64_t platforms, uint64_t num_platform) {

  printf("Received btx_getplatformids_callbacks message\n");
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_GetPlatformIDs(btx_handle, &btx_getplatformids_callbacks);
}
