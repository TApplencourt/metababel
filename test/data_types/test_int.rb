require_relative '../base_test'

class IntTest < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/data_types/cases_int/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/data_types/cases_int/1.callbacks.c'
      },
      {
        btx_component_type: 'SINK',
        btx_component_plugin_name: 'text',
        btx_component_name: 'details',
        btx_compile: false
      }
    ]

    @btx_output_validation = './test/data_types/cases_int/1.btx_log.out'
  end
end
