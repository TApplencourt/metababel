require 'base_test'

class TestSourceTypeUInt64ZeroValue < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downtream_model: './test/cases_source_type_uint/1.btx_model.yaml',
        btx_log_path: './test/cases_source_type_uint/1.1.btx_log.txt'
      }
    ]
  end
end

class TestSourceTypeUInt64MaxValue < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downtream_model: './test/cases_source_type_uint/1.btx_model.yaml',
        btx_log_path: './test/cases_source_type_uint/1.2.btx_log.txt'
      }
    ]
  end
end

class TestSourceTypeUInt32MaxValueNoCastType < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downtream_model: './test/cases_source_type_uint/2.btx_model.yaml',
        btx_log_path: './test/cases_source_type_uint/2.1.btx_log.txt'
      }
    ]
  end
end
