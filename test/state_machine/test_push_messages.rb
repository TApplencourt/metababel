require 'base_test'

class TestPushMessagesAgain < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/state_machine/cases_push_messages/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/state_machine/cases_push_messages/1.source_callbacks.c'
      }
    ]

    @btx_output_validation = './test/state_machine/cases_push_messages/1.btx_log.txt'
  end
end

class TestPushMessagesFromInitialize < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/state_machine/cases_push_messages/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/state_machine/cases_push_messages/2.source_callbacks.c'
      }
    ]

    @btx_output_validation = './test/state_machine/cases_push_messages/1.btx_log.txt'
  end
end

class TestPushMessagesFromFinalize < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/state_machine/cases_push_messages/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/state_machine/cases_push_messages/3.source_callbacks.c'
      }
    ]

    @btx_output_validation = './test/state_machine/cases_push_messages/1.btx_log.txt'
  end
end
