#include "component.h"
#include "dispatch.h"
#include <stdio.h>
#include <assert.h>

struct data_s {
  uint64_t event_1_calls_count;
  uint64_t event_2_calls_count;
};

typedef struct data_s data_t;

void btx_initialize_usr_data(common_data_t *common_data, void **usr_data)
{
  data_t *data = malloc(sizeof(data_t *));
  *usr_data = data;
  
  data->event_1_calls_count = 0;
  data->event_2_calls_count = 0;
}

void btx_finalize_usr_data(common_data_t *common_data, void *usr_data)
{
  data_t *data = (data_t *) usr_data;

  assert(data->event_1_calls_count == 2000);
  assert(data->event_2_calls_count == 2000);

  free(data);
}

static void event_1_0(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_1(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_2(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_3(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_4(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_5(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_6(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_7(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_8(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_9(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_10(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_11(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_12(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_13(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_14(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_15(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_16(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_17(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_18(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_1_19(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_1_calls_count += 1;
}

static void event_2_0(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_1(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_2(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_3(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_4(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_5(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_6(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_7(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_8(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_9(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_10(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_11(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_12(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_13(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_14(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_15(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_16(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_17(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_18(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}

static void event_2_19(
  common_data_t *common_data, void *usr_data,
  bt_bool cf_1, const char* cf_2, uint64_t cf_3, int64_t cf_4, bt_bool pf_1, const char* pf_2, uint64_t pf_3, int64_t pf_4)
{
  data_t *data = (data_t *) usr_data;
  data->event_2_calls_count += 1;
}


void btx_register_usr_callbacks(name_to_dispatcher_t** name_to_dispatcher) {
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_0);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_1);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_2);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_3);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_4);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_5);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_6);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_7);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_8);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_9);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_10);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_11);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_12);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_13);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_14);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_15);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_16);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_17);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_18);
  btx_register_callbacks_event_1(name_to_dispatcher, &event_1_19);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_0);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_1);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_2);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_3);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_4);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_5);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_6);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_7);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_8);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_9);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_10);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_11);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_12);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_13);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_14);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_15);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_16);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_17);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_18);
  btx_register_callbacks_event_2(name_to_dispatcher, &event_2_19);
}
