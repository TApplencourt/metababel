require 'base_test'

class TestFilterOneMessageNoCallbacks < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/case_filter_stream_begin_end/1.btx_model.yaml',
        btx_log_path: './test/case_filter_stream_begin_end/1.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/case_filter_stream_begin_end/1.btx_model.yaml',
        btx_component_downstream_model: './test/case_filter_stream_begin_end/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/case_filter_stream_begin_end/1.callbacks.c'
      },
      {
        btx_component_type: 'SINK',
        btx_component_plugin_name: 'utils',
        btx_component_name: 'counter',
        # Prevent the component compilation which is not needed for babeltrace components.
        btx_compile: false
      }
    ]

    @btx_output_validation = './test/case_filter_stream_begin_end/1.btx_out.txt'
  end
end

class TestFilterOneMessageOneCallback < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/case_filter_stream_begin_end/1.btx_model.yaml',
        btx_log_path: './test/case_filter_stream_begin_end/2.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/case_filter_stream_begin_end/1.btx_model.yaml',
        btx_component_downstream_model: './test/case_filter_stream_begin_end/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/case_filter_stream_begin_end/2.callbacks.c'
      },
      {
        btx_component_type: 'SINK',
        btx_component_plugin_name: 'utils',
        btx_component_name: 'counter',
        # Prevent the component compilation which is not needed for babeltrace components.
        btx_compile: false
      }
    ]
    @btx_output_validation = './test/case_filter_stream_begin_end/2.btx_out.txt'
  end
end