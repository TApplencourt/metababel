require 'base_test'

class TestSinkUserDefinedCastType < Test::Unit::TestCase
  include SinkTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_sink_stream_classes_model/1.btx_model.yaml',
      btx_log_path: './test/cases_sink_stream_classes_model/1.btx_log.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_source',
      btx_component_path: './test/SOURCE.metababel_test',
      btx_usr_header_path: './test/cases_sink_stream_classes_model/1.user_types.h'
    }

    @btx_sink_variables = {
      btx_model_path: './test/cases_sink_stream_classes_model/1.btx_model.yaml',
      btx_callbacks_path: './test/cases_sink_stream_classes_model/1.callbacks.c',
      btx_component_name: 'sink',
      btx_pluggin_name: 'metababel_sink',
      btx_component_path: './test/SINK.metababel_test'
    }
  end

  # Override to include user defined types by command line.
  def subtest_compile_source_component
    assert_command("$CC -o #{btx_source_variables[:btx_component_path]}/#{btx_source_variables[:btx_pluggin_name]}_#{btx_source_variables[:btx_component_name]}.so #{btx_source_variables[:btx_component_path]}/*.c $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -Wall -fpic --shared -I ./test/include/")
  end

  # Override to include user defined types by command line.
  def subtest_compile_sink_component
    assert_command("$CC -o #{btx_sink_variables[:btx_component_path]}/#{btx_sink_variables[:btx_pluggin_name]}_#{btx_sink_variables[:btx_component_name]}.so #{btx_sink_variables[:btx_component_path]}/*.c $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -Wall -fpic --shared -I ./test/include/")
  end
end
