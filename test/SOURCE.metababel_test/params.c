#include "component.h"
#include <babeltrace2/babeltrace.h>
#include <stdio.h>

void btx_read_params(void *btx_handle, params_t *usr_params) {
  common_data_t *common_data = (common_data_t *)btx_handle;
  const bt_value *params = common_data->params;
  (void)params;
}
