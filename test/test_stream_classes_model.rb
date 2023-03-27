require 'base_test'

class TestSourceNoCommonField < Test::Unit::TestCase
  include TestSourceBase
  extend VariableAccessor
  include VariableClassAccessor
  
  def self.startup
    @btx_variables = {
      btx_model_path: './test/test_cases_stream_classes_model/1.btx_model.yaml',
      btx_target_log_path: './test/test_cases_stream_classes_model/1.btx_log.txt',
      btx_component_type: 'SOURCE',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceNoPayloadField < Test::Unit::TestCase
  include TestSourceBase
  extend VariableAccessor
  include VariableClassAccessor
  
  def self.startup
    @btx_variables = {
      btx_model_path: './test/test_cases_stream_classes_model/2.btx_model.yaml',
      btx_target_log_path: './test/test_cases_stream_classes_model/2.btx_log.txt',
      btx_component_type: 'SOURCE',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceNoCommonNoPayloadFields < Test::Unit::TestCase
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_variables = {
      btx_model_path: './test/test_cases_stream_classes_model/3.btx_model.yaml',
      btx_target_log_path: './test/test_cases_stream_classes_model/3.btx_log.txt',
      btx_component_type: 'SOURCE',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end

  def test_generate_source
    `ruby -I./lib ./bin/metababel -d #{btx_variables[:btx_model_path]} -t #{btx_variables[:btx_component_type]} -p #{btx_variables[:btx_pluggin_name]} -c #{btx_variables[:btx_component_name]} -o #{btx_variables[:btx_component_path]} &> /dev/null`
  end
end

class TestSourceCommonPayloadFields < Test::Unit::TestCase
  include TestSourceBase
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_variables = {
      btx_model_path: './test/test_cases_stream_classes_model/4.btx_model.yaml',
      btx_target_log_path: './test/test_cases_stream_classes_model/4.btx_log.txt',
      btx_component_type: 'SOURCE',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceHundredFields < Test::Unit::TestCase
  include TestSourceBase
  extend VariableAccessor
  include VariableClassAccessor
  
  def self.startup
    @btx_variables = {
      btx_model_path: './test/test_cases_stream_classes_model/5.btx_model.yaml',
      btx_target_log_path: './test/test_cases_stream_classes_model/5.btx_log.txt',
      btx_component_type: 'SOURCE',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceDetailsComparisonAllTypes < Test::Unit::TestCase
  include TestSourceBase
  include TestSourceBaseDetails
  extend VariableAccessor
  include VariableClassAccessor
  
  def self.startup
    @btx_variables = {
      btx_model_path: './test/test_cases_stream_classes_model/6.btx_model.yaml',
      btx_target_log_path: './test/test_cases_stream_classes_model/6.btx_details.txt',
      btx_component_type: 'SOURCE',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceDetailsComparisonIntegersNoFieldRange < Test::Unit::TestCase
  include TestSourceBase
  include TestSourceBaseDetails
  extend VariableAccessor
  include VariableClassAccessor
  
  def self.startup
    @btx_variables = {
      btx_model_path: './test/test_cases_stream_classes_model/7.btx_model.yaml',
      btx_target_log_path: './test/test_cases_stream_classes_model/7.btx_details.txt',
      btx_component_type: 'SOURCE',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceDetailsComparisonIntegers64DifferentBases < Test::Unit::TestCase
  include TestSourceBase
  include TestSourceBaseDetails
  extend VariableAccessor
  include VariableClassAccessor
  
  def self.startup
    @btx_variables = {
      btx_model_path: './test/test_cases_stream_classes_model/8.btx_model.yaml',
      btx_target_log_path: './test/test_cases_stream_classes_model/8.btx_details.txt',
      btx_component_type: 'SOURCE',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end

class TestSourceDetailsComparisonIntegers32DifferentBases < Test::Unit::TestCase
  include TestSourceBase
  include TestSourceBaseDetails
  extend VariableAccessor
  include VariableClassAccessor
  
  def self.startup
    @btx_variables = {
      btx_model_path: './test/test_cases_stream_classes_model/9.btx_model.yaml',
      btx_target_log_path: './test/test_cases_stream_classes_model/9.btx_details.txt',
      btx_component_type: 'SOURCE',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end