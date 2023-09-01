require 'base_test'

class TestMatchingCallbackCallingOrder < Test::Unit::TestCase
  # Ensure the calling order of matching callbacks comply the same as defined in the model.
 
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/callbacks/cases_matching_callbacks/2.btx_model.yaml',
        btx_log_path: './test/callbacks/cases_matching_callbacks/2.btx_log.in'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/callbacks/cases_matching_callbacks/2.btx_model.yaml',
        btx_component_downstream_model: './test/callbacks/cases_matching_callbacks/2.btx_model.yaml',
        btx_component_callbacks: './test/callbacks/cases_matching_callbacks/2.btx_callbacks.yaml',
        btx_file_usr_callbacks: './test/callbacks/cases_matching_callbacks/2.callbacks.c'
      }
    ]

    @btx_output_validation = './test/callbacks/cases_matching_callbacks/2.btx_log.out'
  end
end

class TestMatchingAndRegularEventCallbacksDispatchDifferentEvents < Test::Unit::TestCase
  # The matching callbacks dispatch event_1, and event_2 while automatic callbacks dispatch event_3.

  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/callbacks/cases_matching_callbacks/3.btx_model.yaml',
        btx_log_path: './test/callbacks/cases_matching_callbacks/3.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/callbacks/cases_matching_callbacks/3.btx_model.yaml',
        btx_component_downstream_model: './test/callbacks/cases_matching_callbacks/3.btx_model.yaml',
        btx_component_callbacks: './test/callbacks/cases_matching_callbacks/3.btx_callbacks.yaml',
        btx_file_usr_callbacks: './test/callbacks/cases_matching_callbacks/3.callbacks.c'
      },
    ]
  end
end

class TestCallMatchingCallbackWithTimestamp < Test::Unit::TestCase
  # Validate the _timestamp is passed properly in matchinig callbacks.

  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/callbacks/cases_matching_callbacks/4.btx_model.yaml',
        btx_log_path: './test/callbacks/cases_matching_callbacks/4.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/callbacks/cases_matching_callbacks/4.btx_model.yaml',
        btx_component_downstream_model: './test/callbacks/cases_matching_callbacks/4.btx_model.yaml',
        btx_component_callbacks: './test/callbacks/cases_matching_callbacks/4.btx_callbacks.yaml',
        btx_file_usr_callbacks: './test/callbacks/cases_matching_callbacks/4.callbacks.c'
      }
    ]

    @btx_output_validation = './test/callbacks/cases_matching_callbacks/4.btx_log.txt'
  end
end

class TestMatchingTwoEvents < Test::Unit::TestCase
  # One matching expression match more than one event.

  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/callbacks/cases_matching_callbacks/5.btx_model.yaml',
        btx_log_path: './test/callbacks/cases_matching_callbacks/5.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/callbacks/cases_matching_callbacks/5.btx_model.yaml',
        btx_component_downstream_model: './test/callbacks/cases_matching_callbacks/5.btx_model.yaml',
        btx_component_callbacks: './test/callbacks/cases_matching_callbacks/5.btx_callbacks.yaml',
        btx_file_usr_callbacks: './test/callbacks/cases_matching_callbacks/5.callbacks.c'
      }
    ]
  end
end

class TestMatchingEventNameAndMembers < Test::Unit::TestCase
  # 2 events match by name, but just one match both name and arguments.

  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/callbacks/cases_matching_callbacks/6.btx_model.yaml',
        btx_log_path: './test/callbacks/cases_matching_callbacks/6.btx_log.in'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/callbacks/cases_matching_callbacks/6.btx_model.yaml',
        btx_component_downstream_model: './test/callbacks/cases_matching_callbacks/6.btx_model.yaml',
        btx_component_callbacks: './test/callbacks/cases_matching_callbacks/6.btx_callbacks.yaml',
        btx_file_usr_callbacks: './test/callbacks/cases_matching_callbacks/6.callbacks.c'
      }
    ]

    @btx_output_validation = './test/callbacks/cases_matching_callbacks/6.btx_log.out'
  end
end

class TestMatchingSimilarMembers < Test::Unit::TestCase
  # One member regex match more than one member on an event. Should fail.

  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/callbacks/cases_matching_callbacks/7.btx_model.yaml',
        btx_log_path: './test/callbacks/cases_matching_callbacks/7.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/callbacks/cases_matching_callbacks/7.btx_model.yaml',
        btx_component_downstream_model: './test/callbacks/cases_matching_callbacks/7.btx_model.yaml',
        btx_component_callbacks: './test/callbacks/cases_matching_callbacks/7.btx_callbacks.yaml',
        btx_metababel_generation_fail: true
      }
    ]
  end
end

class TestCallMatchingCallbackWithEnvironmentVariables < Test::Unit::TestCase
  # Validate that environment entries are passed properly into matchinig callbacks.

  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/callbacks/cases_matching_callbacks/9.btx_downstream_model.yaml',
        btx_file_usr_callbacks: './test/callbacks/cases_matching_callbacks/9.source_callbacks.c'
      },
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/callbacks/cases_matching_callbacks/9.btx_upstream_model.yaml',
        btx_component_callbacks: './test/callbacks/cases_matching_callbacks/9.btx_callbacks.yaml',
        btx_file_usr_callbacks: './test/callbacks/cases_matching_callbacks/9.sink_callbacks.c'
      }
    ]
  end
end

class TestMatchingEventNameArgNameArgTypeAndArgCastType < Test::Unit::TestCase

  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/callbacks/cases_matching_callbacks/10.btx_upstream_model.yaml',
        btx_log_path: './test/callbacks/cases_matching_callbacks/10.btx_log.in'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/callbacks/cases_matching_callbacks/10.btx_upstream_model.yaml',
        btx_component_downstream_model: './test/callbacks/cases_matching_callbacks/10.btx_downstream_model.yaml',
        btx_component_callbacks: './test/callbacks/cases_matching_callbacks/10.btx_callbacks.yaml',
        btx_file_usr_callbacks: './test/callbacks/cases_matching_callbacks/10.callbacks.c'
      }
    ]

    @btx_output_validation = './test/callbacks/cases_matching_callbacks/10.btx_log.out'
  end
end
