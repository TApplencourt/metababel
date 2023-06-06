require 'base_test'

class TestSourceTypeArrayDynamicLengthFieldPath < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_source_filter_type_array_dynamic/1.btx_model.yaml',
        btx_log_path: './test/cases_source_filter_type_array_dynamic/1.btx_log.txt',
        btx_file_usr_callbacks: './test/cases_source_filter_type_array_dynamic/1.callbacks.c'
      }
    ]

    @btx_output_validation = './test/cases_source_filter_type_array_dynamic/1.btx_log.txt'
  end
end

class TestFilterTypeArrayDynamicLengthFieldPath < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_source_filter_type_array_dynamic/1.btx_model.yaml',
        btx_log_path: './test/cases_source_filter_type_array_dynamic/1.btx_log.txt',
        btx_file_usr_callbacks: './test/cases_source_filter_type_array_dynamic/1.callbacks.c'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_downstream_model: './test/cases_source_filter_type_array_dynamic/1.btx_model.yaml',
        btx_component_upstream_model: './test/cases_source_filter_type_array_dynamic/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/cases_source_filter_type_array_dynamic/2.callbacks.c'
      }
    ]

    @btx_output_validation = './test/cases_source_filter_type_array_dynamic/1.btx_log.txt'
  end
end
