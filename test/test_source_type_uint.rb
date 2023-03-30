require 'base_test'

class TestSourceTypeUInt64ZeroValue < Test::Unit::TestCase
  include SourceTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_source_type_uint/1.btx_model.yaml',
      btx_log_path: './test/cases_source_type_uint/1.1.btx_log.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceTypeUInt64MaxValue < Test::Unit::TestCase
  include SourceTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_source_type_uint/1.btx_model.yaml',
      btx_log_path: './test/cases_source_type_uint/1.2.btx_log.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end

  # Need to include btx_model.yaml in the generation to apply
  # the UINT64 or INT64 macro accordingly for long integers.
  def subtest_generate_source_callbacks
    assert_command("ruby ./test/gen_source.rb -i #{btx_source_variables[:btx_log_path]} -y #{btx_source_variables[:btx_model_path]} -o #{btx_source_variables[:btx_component_path]}/callbacks.c")
  end
end

class TestSourceTypeUInt32MaxValueNoCastType < Test::Unit::TestCase
  include SourceTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_source_type_uint/2.btx_model.yaml',
      btx_log_path: './test/cases_source_type_uint/2.1.btx_log.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end
