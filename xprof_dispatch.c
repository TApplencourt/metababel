#include <babeltrace2/babeltrace.h>
#include "uthash.h"
#include "utarray.h"
#include "dispacher_t.h"
#include "xprof_dispatch.h"
#include <stdio.h>
static void
btx_dispatch_lttng_ust_ze_profiling_event_profiling_results(
  UT_array *callbacks,
  const bt_event *event) {
  int64_t usr_event_cc_f_m_0;
  int64_t usr_event_cc_f_m_1;
  uint64_t usr_event_p_f_m_0;
  {
    const bt_field *event_cc_f = bt_event_borrow_common_context_field_const(event);
    {
      const bt_field *event_cc_f_m_0 = bt_field_structure_borrow_member_field_by_index_const(event_cc_f, 0);
      usr_event_cc_f_m_0 = bt_field_integer_signed_get_value(event_cc_f_m_0);
    }
    {
      const bt_field *event_cc_f_m_1 = bt_field_structure_borrow_member_field_by_index_const(event_cc_f, 1);
      usr_event_cc_f_m_1 = bt_field_integer_signed_get_value(event_cc_f_m_1);
    }
  }
  {
    const bt_field *event_p_f = bt_event_borrow_payload_field_const(event);
    {
      const bt_field *event_p_f_m_0 = bt_field_structure_borrow_member_field_by_index_const(event_p_f, 0);
      usr_event_p_f_m_0 = bt_field_integer_unsigned_get_value(event_p_f_m_0);
    }
  }
  // Call all the callbacks who where registered
  lttng_ust_ze_profiling_event_profiling_results_callback_f **p = NULL;
  while ( ( p = utarray_next(callbacks, p) ) ) {
    (*p)(usr_event_cc_f_m_0, usr_event_cc_f_m_1, usr_event_p_f_m_0);
  }
}

void
btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(name_to_dispatcher_t **name_to_dispatcher, lttng_ust_ze_profiling_event_profiling_results_callback_f *callback)
{
  // Look-up our dispatcher
  name_to_dispatcher_t *s = NULL;
  HASH_FIND_STR(*name_to_dispatcher, "lttng_ust_ze_profiling:event_profiling_results", s);
  if (!s) {
    // We didn't find the dispatcher, so we need to
    // Create it
    s = (name_to_dispatcher_t *) malloc(sizeof(name_to_dispatcher_t));
    s-> name = "lttng_ust_ze_profiling:event_profiling_results";
    s-> dispatcher = &btx_dispatch_lttng_ust_ze_profiling_event_profiling_results;
    utarray_new(s->callbacks, &ut_ptr_icd);
    // and Register it
    HASH_ADD_KEYPTR(hh, *name_to_dispatcher, s->name, strlen(s->name), s);
  }
  utarray_push_back(s->callbacks, &callback);
}

static void
btx_dispatch_lttng_ust_interval_inHost(
  UT_array *callbacks,
  const bt_event *event) {
  const char* usr_event_cc_f_m_0;
  int64_t usr_event_cc_f_m_1;
  uint64_t usr_event_cc_f_m_2;
  const char* usr_event_cc_f_m_3;
  int64_t usr_event_cc_f_m_4;
  const char* usr_event_p_f_m_0;
  uint64_t usr_event_p_f_m_1;
  bt_bool usr_event_p_f_m_2;
  {
    const bt_field *event_cc_f = bt_event_borrow_common_context_field_const(event);
    {
      const bt_field *event_cc_f_m_0 = bt_field_structure_borrow_member_field_by_index_const(event_cc_f, 0);
      usr_event_cc_f_m_0 = bt_field_string_get_value(event_cc_f_m_0);
    }
    {
      const bt_field *event_cc_f_m_1 = bt_field_structure_borrow_member_field_by_index_const(event_cc_f, 1);
      usr_event_cc_f_m_1 = bt_field_integer_signed_get_value(event_cc_f_m_1);
    }
    {
      const bt_field *event_cc_f_m_2 = bt_field_structure_borrow_member_field_by_index_const(event_cc_f, 2);
      usr_event_cc_f_m_2 = bt_field_integer_unsigned_get_value(event_cc_f_m_2);
    }
    {
      const bt_field *event_cc_f_m_3 = bt_field_structure_borrow_member_field_by_index_const(event_cc_f, 3);
      usr_event_cc_f_m_3 = bt_field_string_get_value(event_cc_f_m_3);
    }
    {
      const bt_field *event_cc_f_m_4 = bt_field_structure_borrow_member_field_by_index_const(event_cc_f, 4);
      usr_event_cc_f_m_4 = bt_field_integer_signed_get_value(event_cc_f_m_4);
    }
  }
  {
    const bt_field *event_p_f = bt_event_borrow_payload_field_const(event);
    {
      const bt_field *event_p_f_m_0 = bt_field_structure_borrow_member_field_by_index_const(event_p_f, 0);
      usr_event_p_f_m_0 = bt_field_string_get_value(event_p_f_m_0);
    }
    {
      const bt_field *event_p_f_m_1 = bt_field_structure_borrow_member_field_by_index_const(event_p_f, 1);
      usr_event_p_f_m_1 = bt_field_integer_unsigned_get_value(event_p_f_m_1);
    }
    {
      const bt_field *event_p_f_m_2 = bt_field_structure_borrow_member_field_by_index_const(event_p_f, 2);
      usr_event_p_f_m_2 = bt_field_bit_array_get_value_as_integer(event_p_f_m_2);
    }
  }
  // Call all the callbacks who where registered
  lttng_ust_interval_inHost_callback_f **p = NULL;
  while ( ( p = utarray_next(callbacks, p) ) ) {
    (*p)(usr_event_cc_f_m_0, usr_event_cc_f_m_1, usr_event_cc_f_m_2, usr_event_cc_f_m_3, usr_event_cc_f_m_4, usr_event_p_f_m_0, usr_event_p_f_m_1, usr_event_p_f_m_2);
  }
}

void
btx_register_callbacks_lttng_ust_interval_inHost(name_to_dispatcher_t **name_to_dispatcher, lttng_ust_interval_inHost_callback_f *callback)
{
  // Look-up our dispatcher
  name_to_dispatcher_t *s = NULL;
  HASH_FIND_STR(*name_to_dispatcher, "lttng_ust_interval:inHost", s);
  if (!s) {
    // We didn't find the dispatcher, so we need to
    // Create it
    s = (name_to_dispatcher_t *) malloc(sizeof(name_to_dispatcher_t));
    s-> name = "lttng_ust_interval:inHost";
    s-> dispatcher = &btx_dispatch_lttng_ust_interval_inHost;
    utarray_new(s->callbacks, &ut_ptr_icd);
    // and Register it
    HASH_ADD_KEYPTR(hh, *name_to_dispatcher, s->name, strlen(s->name), s);
  }
  utarray_push_back(s->callbacks, &callback);
}

