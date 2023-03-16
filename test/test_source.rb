require 'test/unit'

class TestSourceFields < Test::Unit::TestCase 
    self.test_order = :defined

    BTX_MODEL_PATH = './test/cases_fields/1.btx_model.yaml'
    BTX_TARGET_LOG_PATH = './test/cases_fields/1.btx_log.txt'
    BTX_PLUGGIN_NAME = 'metababel_tests'
    BTX_COMPONENT_TYPE = 'SOURCE'
    BTX_COMPONENT_NAME = 'source'
    BTX_COMPONENT_PATH = './test/SOURCE.metababel'

    def test_btx_model_exists
        `cat #{BTX_MODEL_PATH} > /dev/null`
        assert $?.success?
    end 

    def test_btx_log_exists
        `cat #{BTX_TARGET_LOG_PATH} > /dev/null`
        assert $?.success?
    end 

    def test_metababel_bin
        `ruby -I./lib ./bin/metababel -h > /dev/null`
        assert $?.success?
    end 

    def test_generate_source
        `ruby -I./lib ./bin/metababel -d #{BTX_MODEL_PATH} -t #{BTX_COMPONENT_TYPE} -p #{BTX_PLUGGIN_NAME} -c #{BTX_COMPONENT_NAME} -o #{BTX_COMPONENT_PATH}`
        assert $?.success?
    end

    def test_generate_source_callbacks
        `ruby ./test/gen_source.rb -t log -i #{BTX_TARGET_LOG_PATH} -o #{BTX_COMPONENT_PATH}/callbacks.c`
        assert $?.success?
    end

    def test_compile_source
        `cc -o #{BTX_COMPONENT_PATH}/#{BTX_PLUGGIN_NAME}_#{BTX_COMPONENT_NAME}.so #{BTX_COMPONENT_PATH}/*.c $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -Wall -fpic --shared -I ./test/include/`
        assert $?.success?
    end

    def test_run_source
        output = `babeltrace2 --plugin-path=#{BTX_COMPONENT_PATH} --component=#{BTX_COMPONENT_TYPE.downcase}.#{BTX_PLUGGIN_NAME}.#{BTX_COMPONENT_NAME}`
        assert $?.success?

        expected_output = File.open(BTX_TARGET_LOG_PATH,"r").read
        assert_equal(expected_output, output)
    end

    def self.shutdown
        `rm -rf #{BTX_COMPONENT_PATH}`
    end

end