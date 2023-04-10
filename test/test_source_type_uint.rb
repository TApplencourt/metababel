require 'base_test'

class TestSourceTypeUInt64ZeroValue < Test::Unit::TestCase
  include SourceTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_source_type_uint/1.btx_model.yaml',
      btx_log_path: './test/cases_source_type_uint/1.1.btx_log.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceTypeUInt64MaxValue < Test::Unit::TestCase
  include SourceTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_source_type_uint/1.btx_model.yaml',
      btx_log_path: './test/cases_source_type_uint/1.2.btx_log.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceTypeUInt32MaxValueNoCastType < Test::Unit::TestCase
  include SourceTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_source_type_uint/2.btx_model.yaml',
      btx_log_path: './test/cases_source_type_uint/2.1.btx_log.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end
