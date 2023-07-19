require 'base_test'

class TestFilterMatchingCallbackSubsetOfMembersInDifferentOrder < Test::Unit::TestCase
  # The matching extract only a subset of the members (in a different order from the set)

  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_matching_callbacks/1.btx_model.yaml',
        btx_log_path: './test/cases_matching_callbacks/1.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/cases_matching_callbacks/1.btx_model.yaml',
        btx_component_downstream_model: './test/cases_matching_callbacks/1.btx_model.yaml',
        btx_component_callbacks: './test/cases_matching_callbacks/1.btx_callbacks.yaml',
        btx_file_usr_callbacks: './test/cases_matching_callbacks/1.callbacks.c'
      }
    ]

    @btx_output_validation = './test/cases_matching_callbacks/1.btx_log.txt'
  end
end

class TestFilterMatchingCallbackCallingOrder < Test::Unit::TestCase
  # Verify the order in with matching are called

  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_matching_callbacks/2.btx_model.yaml',
        btx_log_path: './test/cases_matching_callbacks/2.btx_log.in'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/cases_matching_callbacks/2.btx_model.yaml',
        btx_component_downstream_model: './test/cases_matching_callbacks/2.btx_model.yaml',
        btx_component_callbacks: './test/cases_matching_callbacks/2.btx_callbacks.yaml',
        btx_file_usr_callbacks: './test/cases_matching_callbacks/2.callbacks.c'
      }
    ]

    @btx_output_validation = './test/cases_matching_callbacks/2.btx_log.out'
  end
end

class TestFilterMatchingAndRegularEventCallbacksDispatchDifferentEvents < Test::Unit::TestCase
  # Regular callbacks dispatch event_1 while matching callbacks dispatch event_2.

  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_matching_callbacks/3.btx_model.yaml',
        btx_log_path: './test/cases_matching_callbacks/3.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/cases_matching_callbacks/3.btx_model.yaml',
        btx_component_downstream_model: './test/cases_matching_callbacks/3.btx_model.yaml',
        btx_component_callbacks: './test/cases_matching_callbacks/3.btx_callbacks.yaml',
        btx_file_usr_callbacks: './test/cases_matching_callbacks/3.callbacks.c'
      }
    ]
  end
end

class TestFilterMatchingCallbacksCalledWithTimeStamp < Test::Unit::TestCase
  # Validate the _timestamp is passed properly in matchinig callbacks.

  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_matching_callbacks/4.btx_model.yaml',
        btx_log_path: './test/cases_matching_callbacks/4.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/cases_matching_callbacks/4.btx_model.yaml',
        btx_component_downstream_model: './test/cases_matching_callbacks/4.btx_model.yaml',
        btx_component_callbacks: './test/cases_matching_callbacks/4.btx_callbacks.yaml',
        btx_file_usr_callbacks: './test/cases_matching_callbacks/4.callbacks.c'
      }
    ]

    @btx_output_validation = './test/cases_matching_callbacks/4.btx_log.txt'
  end
end

class TestFilterMatchingTwoEvents < Test::Unit::TestCase
  # Validate one matching match more than one event.

  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_matching_callbacks/5.btx_model.yaml',
        btx_log_path: './test/cases_matching_callbacks/5.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/cases_matching_callbacks/5.btx_model.yaml',
        btx_component_downstream_model: './test/cases_matching_callbacks/5.btx_model.yaml',
        btx_component_callbacks: './test/cases_matching_callbacks/5.btx_callbacks.yaml',
        btx_file_usr_callbacks: './test/cases_matching_callbacks/5.callbacks.c'
      }
    ]
  end
end
