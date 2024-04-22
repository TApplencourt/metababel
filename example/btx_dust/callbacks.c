#include <inttypes.h>
#include <metababel/metababel.h>
#include <stdio.h>

struct usr_data_s {
  /* Input file */
  FILE *file;
  /* Buffers to read data from the input file */
  char name_buffer[32];
  char msg_buffer[1024];
};
typedef struct usr_data_s usr_data_t;

void btx_initialize_usr_data(void **usr_data) {
  *usr_data = (usr_data_t *)calloc(1, sizeof(usr_data_t));
}

void btx_read_params(void *usr_data,
                     btx_params_t *usr_params) {
  usr_data_t *data = (usr_data_t *)usr_data;
  data->file = fopen(usr_params->path, "r");
}

void btx_push_usr_messages(void *btx_handle, void *usr_data,
                           btx_source_status_t *status) {
  usr_data_t *data = (usr_data_t *)usr_data;
  int64_t timestamp;
  uint64_t extra_us;
  /* Try to read a line from the input file into individual tokens */
  int count =
      fscanf(data->file, "%" PRIu64 " %" PRIu64 " %s %[^\n]", &timestamp,
             &extra_us, &data->name_buffer[0], &data->msg_buffer[0]);
  /* Reached the end of the file? */
  if (count == EOF || feof(data->file)) {
    *status = BTX_SOURCE_END;
    return;
  }

  /*
   * At this point `timestamp` contains seconds since the Unix epoch.
   * Multiply it by 1,000,000,000 to get nanoseconds since the Unix
   * epoch because the stream's clock's frequency is 1 GHz.
   */
  timestamp *= INT64_C(1000000000);

  /* Add the extra microseconds (as nanoseconds) to `timestamp` */
  timestamp += extra_us * INT64_C(1000);

  /* Choose the correct event class, depending on the event name token */
  if (strcmp(data->name_buffer, "send-msg") == 0)
    btx_push_message_send_msg(btx_handle, timestamp, data->msg_buffer);
  else if (strcmp(data->name_buffer, "recv-msg") == 0)
    btx_push_message_recv_msg(btx_handle, timestamp, data->msg_buffer);
  else if (strcmp(data->name_buffer, "sched_switch") == 0)
    btx_push_message_sched_switch(btx_handle, timestamp, data->msg_buffer);
  else if (strcmp(data->name_buffer, "rcu_utilization") == 0)
    btx_push_message_rcu_utilization(btx_handle, timestamp, data->msg_buffer);
  else
    btx_push_message_kmem_kfree(btx_handle, timestamp, data->msg_buffer);

  *status = BTX_SOURCE_OK;
}

void btx_finalize_usr_data(void *usr_data) {
  usr_data_t *data = (usr_data_t *)usr_data;
  /* Close the input file */
  fclose(data->file);
  /* Free the allocated structure */
  free(data);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_component(btx_handle,
                                              &btx_initialize_usr_data);
  btx_register_callbacks_read_params(btx_handle, &btx_read_params);
  btx_register_callbacks_finalize_component(btx_handle, &btx_finalize_usr_data);
  btx_register_callbacks_push_usr_messages(btx_handle, &btx_push_usr_messages);
}
