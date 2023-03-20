require 'base_test'

# Zero value test.
class TestSourceTypeUInt1 < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/cases_type_uint/1.btx_model.yaml',
            btx_target_log_path: './test/cases_type_uint/1.1.btx_log.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests',
            btx_component_path: './test/SOURCE.metababel'
        }
    end 

    def self.shutdown
        FileUtils.remove_dir(@btx_variables[:btx_component_path],true)
    end
end

# Large integer test.
class TestSourceTypeUInt2 < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/cases_type_uint/1.btx_model.yaml',
            btx_target_log_path: './test/cases_type_uint/1.2.btx_log.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests',
            btx_component_path: './test/SOURCE.metababel'
        }
    end 

    def self.shutdown
        FileUtils.remove_dir(@btx_variables[:btx_component_path],true)
    end
end
