require 'test/unit'

module TestSourceBase

    def btx_model_exists
        assert(File.file?(btx_variables[:btx_model_path]))
    end 

    def btx_log_exists
        assert(File.file?(btx_variables[:btx_target_log_path]))
    end 

    def metababel_bin
        `ruby -I./lib ./bin/metababel -h > /dev/null`
        assert($?.success?)
    end 

    def generate_source
        `ruby -I./lib ./bin/metababel -d #{btx_variables[:btx_model_path]} -t #{btx_variables[:btx_component_type]} -p #{btx_variables[:btx_pluggin_name]} -c #{btx_variables[:btx_component_name]} -o #{btx_variables[:btx_component_path]}`
        assert($?.success?)
    end

    def generate_source_callbacks
        `ruby ./test/gen_source.rb -t log -i #{btx_variables[:btx_target_log_path]} -o #{btx_variables[:btx_component_path]}/callbacks.c`
        assert($?.success?)
    end

    def compile_source
        `cc -o #{btx_variables[:btx_component_path]}/#{btx_variables[:btx_pluggin_name]}_#{btx_variables[:btx_component_name]}.so #{btx_variables[:btx_component_path]}/*.c $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -Wall -fpic --shared -I ./test/include/`
        assert($?.success?)
    end

    def run_source
        output = `babeltrace2 --plugin-path=#{btx_variables[:btx_component_path]} --component=#{btx_variables[:btx_component_type].downcase}.#{btx_variables[:btx_pluggin_name]}.#{btx_variables[:btx_component_name]}`
        assert($?.success?)

        expected_output = File.open(btx_variables[:btx_target_log_path],"r").read
        assert_equal(expected_output, output)
    end

    def test_global
        btx_model_exists
        btx_log_exists
        metababel_bin
        generate_source
        generate_source_callbacks
        compile_source
        run_source
    end 
end

module VariableAccessor
    attr_reader :btx_variables
end

module VariableClassAccessor
    def btx_variables
        self.class.btx_variables
    end
end
