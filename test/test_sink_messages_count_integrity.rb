require 'base_test'

class TestSinkCaseTwoEventClasesOneCallbackPerEventHundredMessagesOnBothEvents < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_sink_messages_count_integrity/1.btx_model.yaml',
        btx_log_path: './test/cases_sink_messages_count_integrity/1.btx_log.txt'
      },
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/cases_sink_messages_count_integrity/1.btx_model.yaml',

        # TODO: Interersing, two separe components can not have the same plugging_name - component_name
        # even when the component type is different, e.g.,  sink.pluggin_name.component_name vs source.plugging_name.component_name
        btx_component_name: 'sink_pluggin',
        btx_component_plugin_name: 'sink_component',
        btx_file_usr_callbacks: './test/cases_sink_messages_count_integrity/1.callbacks.c'
      }
    ]
  end
end

class TestSinkCaseTwoEventClasesOneCallbackPerEventSeventyThreeMessagesInOneEventZeroInTheOther < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_sink_messages_count_integrity/1.btx_model.yaml',
        btx_log_path: './test/cases_sink_messages_count_integrity/2.btx_log.txt'
      },
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/cases_sink_messages_count_integrity/1.btx_model.yaml',
        btx_component_name: 'sink_pluggin',
        btx_component_plugin_name: 'sink_component',
        btx_file_usr_callbacks: './test/cases_sink_messages_count_integrity/2.callbacks.c'
      }
    ]
  end
end

class TestSinkCaseTwoEventClasesOneCallbackRegisteredHundredMessagesOnBothEvents < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_sink_messages_count_integrity/1.btx_model.yaml',
        btx_log_path: './test/cases_sink_messages_count_integrity/1.btx_log.txt'
      },
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/cases_sink_messages_count_integrity/1.btx_model.yaml',
        btx_component_name: 'sink_pluggin',
        btx_component_plugin_name: 'sink_component',
        btx_file_usr_callbacks: './test/cases_sink_messages_count_integrity/3.callbacks.c'
      }
    ]
  end
end

class TestSinkUserRegistersTheWrongCallbacks < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/cases_sink_messages_count_integrity/4.btx_model.yaml',
        btx_file_usr_callbacks: './test/cases_sink_messages_count_integrity/4.callbacks.c',
        btx_compilation_should_fail: true
      }
    ]
  end
end
