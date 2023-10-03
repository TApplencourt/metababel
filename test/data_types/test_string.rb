require_relative '../base_test'

class StringTest < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/data_types/cases_string/1.btx_model.yaml',
        btx_log_path: './test/data_types/cases_string/1.btx_log.in',
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/data_types/cases_string/1.btx_model.yaml',
        btx_component_downstream_model: './test/data_types/cases_string/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/data_types/cases_string/1.filter_callbacks.c',
      },
      {
        btx_component_type: 'SINK',
        btx_component_plugin_name: 'text',
        btx_component_name: 'details',
        btx_compile: false,
      },
    ]

    @btx_output_validation = './test/data_types/cases_string/1.btx_log.out'
  end
end
