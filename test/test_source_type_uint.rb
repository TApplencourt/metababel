require 'base_test'

class TestSourceTypeUInt64ZeroValue < Test::Unit::TestCase
  include TestSourceBase
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_variables = {
      btx_model_path: './test/test_cases_type_uint/1.btx_model.yaml',
      btx_target_log_path: './test/test_cases_type_uint/1.1.btx_log.txt',
      btx_component_type: 'SOURCE',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceTypeUInt64MaxValue < Test::Unit::TestCase
  include TestSourceBase
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_variables = {
      btx_model_path: './test/test_cases_type_uint/1.btx_model.yaml',
      btx_target_log_path: './test/test_cases_type_uint/1.2.btx_log.txt',
      btx_component_type: 'SOURCE',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end

  # We need to use the btx_model.yaml in the generation to apply
  # the UINT64 or INT64 macro accordingly for long integers.
  def subtest_generate_source_callbacks
    `ruby ./test/gen_source.rb -i #{btx_variables[:btx_target_log_path]} -y #{btx_variables[:btx_model_path]} -o #{btx_variables[:btx_component_path]}/callbacks.c`
    assert($?.success?)
  end
end

class TestSourceTypeUInt32MaxValueNoCastType < Test::Unit::TestCase
  include TestSourceBase
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_variables = {
      btx_model_path: './test/test_cases_type_uint/2.btx_model.yaml',
      btx_target_log_path: './test/test_cases_type_uint/2.1.btx_log.txt',
      btx_component_type: 'SOURCE',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end
