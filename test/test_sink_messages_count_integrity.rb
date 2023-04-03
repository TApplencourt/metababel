require 'base_test'

class TestSinkCaseTwoEventClasesOneCallbackPerEventHundredMessagesOnBothEvents < Test::Unit::TestCase
  include SinkTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_sink_messages_count_integrity/1.btx_model.yaml',
      btx_log_path: './test/cases_sink_messages_count_integrity/1.btx_log.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_source',
      btx_component_path: './test/SOURCE.metababel_test'
    }

    @btx_sink_variables = {
      btx_model_path: './test/cases_sink_messages_count_integrity/1.btx_model.yaml',
      btx_callbacks_path: './test/cases_sink_messages_count_integrity/1.callbacks.c',
      btx_component_name: 'sink',
      btx_pluggin_name: 'metababel_sink',
      btx_component_path: './test/SINK.metababel_test'
    }
  end
end

class TestSinkCaseTwoEventClasesOneCallbackPerEventSeventyThreeMessagesInOneEventZeroInTheOther < Test::Unit::TestCase
  include SinkTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_sink_messages_count_integrity/1.btx_model.yaml',
      btx_log_path: './test/cases_sink_messages_count_integrity/2.btx_log.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_source',
      btx_component_path: './test/SOURCE.metababel_test'
    }

    @btx_sink_variables = {
      btx_model_path: './test/cases_sink_messages_count_integrity/1.btx_model.yaml',
      btx_callbacks_path: './test/cases_sink_messages_count_integrity/2.callbacks.c',
      btx_component_name: 'sink',
      btx_pluggin_name: 'metababel_sink',
      btx_component_path: './test/SINK.metababel_test'
    }
  end
end

class TestSinkCaseTwoEventClasesOneCallbackRegisteredHundredMessagesOnBothEvents < Test::Unit::TestCase
  include SinkTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_sink_messages_count_integrity/1.btx_model.yaml',
      btx_log_path: './test/cases_sink_messages_count_integrity/1.btx_log.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_source',
      btx_component_path: './test/SOURCE.metababel_test'
    }

    @btx_sink_variables = {
      btx_model_path: './test/cases_sink_messages_count_integrity/1.btx_model.yaml',
      btx_callbacks_path: './test/cases_sink_messages_count_integrity/3.callbacks.c',
      btx_component_name: 'sink',
      btx_pluggin_name: 'metababel_sink',
      btx_component_path: './test/SINK.metababel_test'
    }
  end
end

class TestSinkUserRegistersTheWrongCallbacks < Test::Unit::TestCase
  include SinkTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_sink_variables = {
      btx_model_path: './test/cases_sink_messages_count_integrity/4.btx_model.yaml',
      btx_callbacks_path: './test/cases_sink_messages_count_integrity/4.callbacks.c',
      btx_component_name: 'sink',
      btx_pluggin_name: 'metababel_sink',
      btx_component_path: './test/SINK.metababel_test'
    }
  end

  # Override to not check btx_log.txt since not needed.
  def subtest_check_source_preconditions
    assert_file_exists(btx_source_variables[:btx_model_path])
    assert_command('ruby -I./lib ./bin/metababel -h')
  end

  # Override to generate an empty source.
  def subtest_generate_source_callbacks
    assert_command("ruby ./test/gen_source.rb -o #{btx_source_variables[:btx_component_path]}/callbacks.c")
  end

  # Override to check compile failure.
  def subtest_compile_sink_component
    refute_command("cc -o #{btx_sink_variables[:btx_component_path]}/#{btx_sink_variables[:btx_pluggin_name]}_#{btx_sink_variables[:btx_component_name]}.so #{btx_sink_variables[:btx_component_path]}/*.c $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -Werror -Wall -fpic --shared -I ./test/include/")
  end

  # Override to not execute the source subtests.
  def test_sink
    subtest_check_sink_preconditions
    subtest_generate_sink_component
    subtest_generate_sink_callbacks
    subtest_compile_sink_component
  end
end
