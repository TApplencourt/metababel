#pragma once
#include "component.h"
#include <babeltrace2/babeltrace.h>
#ifdef __cplusplus
extern "C" {
#endif
void btx_downstream_push_message(struct common_data_s *common_data,
                                 const bt_message *message);

bt_trace_class *
btx_downstream_trace_class_create_rec(bt_self_component *self_component);

bt_trace *btx_downstream_trace_create_rec(bt_trace_class *trace_class);

void btx_push_messages_stream_beginning(struct common_data_s *common_data);
void btx_push_messages_stream_end(struct common_data_s *common_data);

void btx_push_message_lttng_host(
    struct common_data_s *common_data,
    const char* hostname, int64_t vpid, uint64_t vtid, int64_t ts, int64_t backend, const char* name, uint64_t dur, bt_bool err);
void btx_push_message_lttng_device(
    struct common_data_s *common_data,
    const char* hostname, int64_t vpid, uint64_t vtid, int64_t ts, int64_t backend, const char* name, uint64_t dur, uint64_t did, uint64_t sdid, bt_bool err, const char* metadata);
void btx_push_message_lttng_traffic(
    struct common_data_s *common_data,
    const char* hostname, int64_t vpid, uint64_t vtid, int64_t ts, int64_t backend, const char* name, uint64_t size);
void btx_push_message_lttng_device_name(
    struct common_data_s *common_data,
    const char* hostname, int64_t vpid, uint64_t vtid, int64_t ts, int64_t backend, const char* name, uint64_t did);
void btx_push_message_lttng_ust_thapi_metadata(
    struct common_data_s *common_data,
    const char* hostname, int64_t vpid, uint64_t vtid, int64_t ts, int64_t backend, const char* metadata);
#ifdef __cplusplus
}
#endif
