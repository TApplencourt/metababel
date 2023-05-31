require 'base_test'

class TestFilterMatchingCallbacksCalled < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_filter_matching_callbacks/1.btx_model.yaml',
        btx_log_path: './test/cases_filter_matching_callbacks/1.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/cases_filter_matching_callbacks/1.btx_model.yaml',
        btx_component_downstream_model: './test/cases_filter_matching_callbacks/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/cases_filter_matching_callbacks/1.callbacks.c'
      }
    ]
  end
end

class TestFilterMatchingNoCallbacksCalled < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_filter_matching_callbacks/1.btx_model.yaml',
        btx_log_path: './test/cases_filter_matching_callbacks/1.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/cases_filter_matching_callbacks/1.btx_model.yaml',
        btx_component_downstream_model: './test/cases_filter_matching_callbacks/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/cases_filter_matching_callbacks/2.callbacks.c'
      }
    ]
  end
end

class TestFilterMatchingCallbacksAndRegularDistapacher < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_filter_matching_callbacks/1.btx_model.yaml',
        btx_log_path: './test/cases_filter_matching_callbacks/1.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/cases_filter_matching_callbacks/1.btx_model.yaml',
        btx_component_downstream_model: './test/cases_filter_matching_callbacks/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/cases_filter_matching_callbacks/3.callbacks.c'
      }
    ]
  end
end

class TestFilterMatchingCallbacksAlternateTrueFalse < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_filter_matching_callbacks/2.btx_model.yaml',
        btx_log_path: './test/cases_filter_matching_callbacks/1.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/cases_filter_matching_callbacks/2.btx_model.yaml',
        btx_component_downstream_model: './test/cases_filter_matching_callbacks/2.btx_model.yaml',
        btx_file_usr_callbacks: './test/cases_filter_matching_callbacks/4.callbacks.c'
      }
    ]
  end
end
