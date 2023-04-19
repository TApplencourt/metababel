require 'base_test'

class TestSourceTypeStringEmptyValue < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_source_type_string/1.btx_model.yaml',
        btx_log_path: './test/cases_source_type_string/1.1.btx_log.txt'
      }
    ]
  end
end

class TestSourceTypeStringLong < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_source_type_string/1.btx_model.yaml',
        btx_log_path: './test/cases_source_type_string/1.2.btx_log.txt'
      }
    ]
  end
end

class TestSourceTypeStringNestingPattern < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_source_type_string/1.btx_model.yaml',
        btx_log_path: './test/cases_source_type_string/1.3.btx_log.txt'
      }
    ]
  end
end
