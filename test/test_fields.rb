require 'base_test'

class TestSourceFields1 < Test::Unit::TestCase
    include TestSourceBaseSuccess
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/cases_fields/1.btx_model.yaml',
            btx_target_log_path: './test/cases_fields/1.btx_log.txt',
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

class TestSourceFields2 < Test::Unit::TestCase
    include TestSourceBaseSuccess
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/cases_fields/2.btx_model.yaml',
            btx_target_log_path: './test/cases_fields/2.btx_log.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests_2',
            btx_component_path: './test/SOURCE.metababel_2'
        }
    end 

    def self.shutdown
        FileUtils.remove_dir(@btx_variables[:btx_component_path],true)
    end
end

class TestSourceFields3 < Test::Unit::TestCase
    include TestSourceBaseFail
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/cases_fields/3.btx_model.yaml',
            btx_target_log_path: './test/cases_fields/3.btx_log.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests_3',
            btx_component_path: './test/SOURCE.metababel_3'
        }
    end 

    def self.shutdown
        FileUtils.remove_dir(@btx_variables[:btx_component_path],true)
    end
end

class TestSourceFields4 < Test::Unit::TestCase
    include TestSourceBaseSuccess
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/cases_fields/4.btx_model.yaml',
            btx_target_log_path: './test/cases_fields/4.btx_log.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests_4',
            btx_component_path: './test/SOURCE.metababel_4'
        }
    end 

    def self.shutdown
        FileUtils.remove_dir(@btx_variables[:btx_component_path],true)
    end
end

class TestSourceFields5 < Test::Unit::TestCase
    include TestSourceBaseSuccess
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/cases_fields/5.btx_model.yaml',
            btx_target_log_path: './test/cases_fields/5.btx_log.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests_5',
            btx_component_path: './test/SOURCE.metababel_5'
        }
    end 

    def self.shutdown
        FileUtils.remove_dir(@btx_variables[:btx_component_path],true)
    end
end