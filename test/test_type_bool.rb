require 'base_test'

class TestSourceTypeBoolTrueValue < Test::Unit::TestCase
  include TestSourceBase
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_variables = {
      btx_model_path: './test/test_cases_type_bool/1.btx_model.yaml',
      btx_target_log_path: './test/test_cases_type_bool/1.1.btx_log.txt',
      btx_component_type: 'SOURCE',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceTypeBoolFalseValue < Test::Unit::TestCase
  include TestSourceBase
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_variables = {
      btx_model_path: './test/test_cases_type_bool/1.btx_model.yaml',
      btx_target_log_path: './test/test_cases_type_bool/1.2.btx_log.txt',
      btx_component_type: 'SOURCE',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end
