#include <metababel/metababel.h>
#include <stdbool.h>
#include <string.h>

struct distill {
  const char *names_value;
};

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  *usr_data = calloc(1, sizeof(struct distill));
}

void btx_read_params(void *btx_handle, void *usr_data, btx_params_t *usr_params) {
  ((struct distill *)usr_data)->names_value = usr_params->names;
}

void btx_finalize_usr_data(void *btx_handle, void *usr_data) {
  struct distill *data = (struct distill *)usr_data;
  free(data);
}

static void btx_filter_condition(void *btx_handle, void *usr_data, const char *stream_class_name, const char *event_class_name, bool *matched, int64_t timestamp)
{
  struct distill *data = (struct distill *)usr_data;

  int str_size = strlen(data->names_value);
  char str[str_size];

  strcpy(str, data->names_value);

  bool ocurrence = false;

  char *ptr = strtok(str, ",");
  while(ptr != NULL && !ocurrence)
  {
    ocurrence = (strcmp(ptr,event_class_name) == 0);
    ptr = strtok(NULL, ",");
  }

  // If the event_class_name is found in 'data->names_value', the associated callback is called,
  // this resulting in the event being discared.
  *matched = ocurrence;
}

static void btx_filter_callback(void *btx_handle, void *usr_data, const char *stream_class_name, const char *event_class_name, int64_t timestamp) {}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_usr_data(btx_handle, &btx_initialize_usr_data);
  btx_register_callbacks_finalize_usr_data(btx_handle, &btx_finalize_usr_data);
  btx_register_callbacks_read_params(btx_handle, &btx_read_params);
  btx_register_matching_callback_sc(btx_handle, &btx_filter_condition, &btx_filter_callback);
}
