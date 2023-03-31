#include "component.h"
#include "create.h"
#include <inttypes.h>

struct usr_data_s {
    uint64_t i;
    int count;
};

void btx_initialize_usr_data(common_data_t *common_data, void **usr_data) {
    struct usr_data_s *data = (struct usr_data_s *)  malloc(sizeof(struct usr_data_s));
    *usr_data = data;
    data->i = 0;
    data->count = 4;
}

btx_source_status_t btx_push_usr_messages(struct common_data_s *common_data, void *usr_data) {
    struct usr_data_s *data = (struct usr_data_s *) usr_data;
    btx_push_message_event_2(common_data, data->i);
    data->i++;
    if (data->i < data->count)
	return BTX_SOURCE_OK;
    return BTX_SOURCE_END;
}
