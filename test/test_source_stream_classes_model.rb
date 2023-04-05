require 'base_test'

class TestSourceNoCommonField < Test::Unit::TestCase
  include SourceTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_source_stream_classes_model/1.btx_model.yaml',
      btx_log_path: './test/cases_source_stream_classes_model/1.btx_log.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_test',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceNoPayloadField < Test::Unit::TestCase
  include SourceTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_source_stream_classes_model/2.btx_model.yaml',
      btx_log_path: './test/cases_source_stream_classes_model/2.btx_log.txt',
      btx_component_type: 'SOURCE',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceNoCommonNoPayloadFields < Test::Unit::TestCase
  include SourceTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_source_stream_classes_model/3.btx_model.yaml',
      btx_log_path: './test/cases_source_stream_classes_model/3.btx_log.txt',
      btx_component_type: 'SOURCE',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end

  # Override to test expected failing.
  def subtest_generate_source_component
    refute_command("ruby -I./lib ./bin/metababel -d #{btx_source_variables[:btx_model_path]} -t SOURCE -p #{btx_source_variables[:btx_pluggin_name]} -c #{btx_source_variables[:btx_component_name]} -o #{btx_source_variables[:btx_component_path]}")
  end

  # Override to prevent the execution of the whole subtests.
  def test_source
    subtest_check_source_preconditions
    subtest_generate_source_component
  end
end

class TestSourceCommonPayloadFields < Test::Unit::TestCase
  include SourceTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_source_stream_classes_model/4.btx_model.yaml',
      btx_log_path: './test/cases_source_stream_classes_model/4.btx_log.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceHundredFields < Test::Unit::TestCase
  include SourceTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_source_stream_classes_model/5.btx_model.yaml',
      btx_log_path: './test/cases_source_stream_classes_model/5.btx_log.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceDetailsComparisonAllTypes < Test::Unit::TestCase
  include SourceTest
  include SourceDetailSubtests
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_source_stream_classes_model/6.btx_model.yaml',
      btx_log_path: './test/cases_source_stream_classes_model/6.btx_details.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceDetailsComparisonIntegersNoFieldRange < Test::Unit::TestCase
  include SourceTest
  include SourceDetailSubtests
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_source_stream_classes_model/7.btx_model.yaml',
      btx_log_path: './test/cases_source_stream_classes_model/7.btx_details.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceDetailsComparisonIntegers64DifferentBases < Test::Unit::TestCase
  include SourceTest
  include SourceDetailSubtests
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_source_stream_classes_model/8.btx_model.yaml',
      btx_log_path: './test/cases_source_stream_classes_model/8.btx_details.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceDetailsComparisonIntegers32DifferentBases < Test::Unit::TestCase
  include SourceTest
  include SourceDetailSubtests
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_source_stream_classes_model/9.btx_model.yaml',
      btx_log_path: './test/cases_source_stream_classes_model/9.btx_details.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end
