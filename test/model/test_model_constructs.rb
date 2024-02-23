require 'base_test'

class TestNoCommonNoPayloadFields < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/model/cases_model_constructs/1.btx_model.yaml',
      },
    ]
  end
end

class TestNoPayloadField < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/model/cases_model_constructs/2.btx_model.yaml',
      },
    ]
  end
end

class TestNoCommonField < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/model/cases_model_constructs/3.btx_model.yaml',
      },
    ]
  end
end

class TestCommonAndPayloadFields < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/model/cases_model_constructs/4.btx_model.yaml',
      },
    ]
  end
end

class TestNoNameForStreamClass < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/model/cases_model_constructs/5.btx_model.yaml',
        btx_metababel_generation_fail: true,
      },
    ]
  end
end

class TestNoNameForEventClass < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/model/cases_model_constructs/6.btx_model.yaml',
        btx_metababel_generation_fail: true,
      },
    ]
  end
end

class TestEventNameDuplicatedOnDifferentStreams < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/model/cases_model_constructs/7.btx_model.yaml',
        btx_metababel_generation_fail: true,
      },
    ]
  end
end

class TestEventNameDuplicatedOnTheSameStream < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/model/cases_model_constructs/8.btx_model.yaml',
        btx_metababel_generation_fail: true,
      },
    ]
  end
end

class TestPacketContextField < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/model/cases_model_constructs/9.btx_model.yaml',
        btx_log_path: './test/model/cases_model_constructs/9.btx_log.txt',
      },
    ]
    @btx_output_validation = './test/model/cases_model_constructs/9.btx_log.txt'
  end
end
