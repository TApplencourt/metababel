require_relative '../base_test'

class BoolTest < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/data_types/cases_bool/1.btx_model.yaml',
        btx_log_path: './test/data_types/cases_bool/1.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/data_types/cases_bool/1.btx_model.yaml',
        btx_component_downstream_model: './test/data_types/cases_bool/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/data_types/cases_bool/1.filter_callbacks.c'
      }
    ]

    @btx_output_validation = './test/data_types/cases_bool/1.btx_log.txt'
  end
end
