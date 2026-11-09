require 'base_test'

# Round-trip a fixed-length BLOB carrying the raw bytes of a struct: the source
# pushes a known struct, the sink reconstructs it via memcpy and asserts.
class TestBlobStatic < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/data_types/cases_blob_static/1.btx_model.yaml',
        btx_file_usr_header_path: './test/data_types/cases_blob_static/1.usr_header.h',
        btx_component_usr_header_file: '1.usr_header.h',
        btx_file_usr_callbacks: './test/data_types/cases_blob_static/1.source_callbacks.c',
      },
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/data_types/cases_blob_static/1.btx_model.yaml',
        btx_file_usr_header_path: './test/data_types/cases_blob_static/1.usr_header.h',
        btx_component_usr_header_file: '1.usr_header.h',
        btx_file_usr_callbacks: './test/data_types/cases_blob_static/1.sink_callbacks.c',
      },
    ]
  end
end
