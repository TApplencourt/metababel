require 'test/unit'
require 'open3'

module Assertions
  def assert_file_exists(file_path)
    assert(File.file?(file_path), "File '#{file_path}' does not exists.")
  end

  def assert_command(cmd)
    _, stderr_str, exit_code = Open3.capture3(*cmd)
    raise Exception, "> #{cmd}\n#{stderr_str}" unless exit_code == 0
  end

  def assert_command_stdout(cmd, expected_stdout)
    stdout_str, stderr_str, exit_code = Open3.capture3(cmd)
    raise Exception, stderr_str unless exit_code == 0

    assert_equal(expected_stdout, stdout_str)
  end

  def refute_command(cmd)
    _, stderr_str, exit_code = Open3.capture3(cmd)
    raise Exception, stderr_str unless exit_code != 0
  end
end

module SourceSubtests
  include Assertions

  def subtest_check_source_preconditions
    assert_file_exists(btx_source_variables[:btx_model_path])
    assert_file_exists(btx_source_variables[:btx_log_path])
    assert_command('ruby -I./lib ./bin/metababel -h')
  end

  def subtest_generate_source_component
    assert_command("ruby -I./lib ./bin/metababel -d #{btx_source_variables[:btx_model_path]} -t SOURCE -p #{btx_source_variables[:btx_pluggin_name]} -c #{btx_source_variables[:btx_component_name]} -o #{btx_source_variables[:btx_component_path]}")
  end

  def subtest_generate_source_callbacks
    assert_command("ruby ./test/gen_source.rb -i #{btx_source_variables[:btx_log_path]} -o #{btx_source_variables[:btx_component_path]}/callbacks.c")
  end

  def subtest_compile_source_component
    assert_command("${CC:-cc} -o #{btx_source_variables[:btx_component_path]}/#{btx_source_variables[:btx_pluggin_name]}_#{btx_source_variables[:btx_component_name]}.so #{btx_source_variables[:btx_component_path]}/*.c #{btx_source_variables[:btx_component_path]}/metababel/*.c -I ./test/include/  -I#{btx_source_variables[:btx_component_path]}/ $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) $CFLAGS -fpic --shared")
  end

  def subtest_run_source_component
    expected_output = File.open(btx_source_variables[:btx_log_path], 'r').read
    command = <<~TEXT
      babeltrace2 --plugin-path=#{btx_source_variables[:btx_component_path]} \
        --component=source.#{btx_source_variables[:btx_pluggin_name]}.#{btx_source_variables[:btx_component_name]}
    TEXT
    assert_command_stdout(command, expected_output)
  end
end

module SourceSubtestsDetail
  # Generate a source with no messages.
  def subtest_generate_source_callbacks
    assert_command("ruby ./test/gen_source.rb -o #{btx_source_variables[:btx_component_path]}/callbacks.c")
  end

  # Compare with text.details in place of log.
  def subtest_run_source_component
    expected_output = File.open(btx_source_variables[:btx_log_path], 'r').read
    command = <<~TEXT
      babeltrace2 --plugin-path=#{btx_source_variables[:btx_component_path]} \
        --component=source.#{btx_source_variables[:btx_pluggin_name]}.#{btx_source_variables[:btx_component_name]} \
        --component=sink.text.details
    TEXT
    assert_command_stdout(command, expected_output)
  end
end

module SinkSubtests
  include Assertions

  def subtest_check_sink_preconditions
    assert_file_exists(btx_sink_variables[:btx_model_path])
    assert_command('ruby -I./lib ./bin/metababel -h')
  end

  def subtest_generate_sink_component
    assert_command("ruby -I./lib ./bin/metababel -u #{btx_sink_variables[:btx_model_path]} -t SINK -p #{btx_sink_variables[:btx_pluggin_name]} -c #{btx_sink_variables[:btx_component_name]} -o #{btx_sink_variables[:btx_component_path]}")
  end

  def subtest_generate_sink_callbacks
    assert_nothing_raised do
      FileUtils.cp(btx_sink_variables[:btx_callbacks_path], btx_sink_variables[:btx_component_path])
    end
  end
  def subtest_compile_sink_component
    assert_command("${CC:-cc} -o #{btx_sink_variables[:btx_component_path]}/#{btx_sink_variables[:btx_pluggin_name]}_#{btx_sink_variables[:btx_component_name]}.so #{btx_sink_variables[:btx_component_path]}/*.c #{btx_sink_variables[:btx_component_path]}/metababel/*.c -I ./test/include/  -I#{btx_sink_variables[:btx_component_path]}/ $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) $CFLAGS -fpic --shared")
  end

  def subtest_run_source_sink_components
    command = <<~TEXT
      babeltrace2 --plugin-path=#{btx_source_variables[:btx_component_path]}:#{btx_sink_variables[:btx_component_path]} \
        --component=source.#{btx_source_variables[:btx_pluggin_name]}.#{btx_source_variables[:btx_component_name]} \
        --component=sink.#{btx_sink_variables[:btx_pluggin_name]}.#{btx_sink_variables[:btx_component_name]}
    TEXT
    assert_command(command)
  end
end

module SourceTest
  include SourceSubtests

  def test_source
    subtest_check_source_preconditions
    subtest_generate_source_component
    subtest_generate_source_callbacks
    subtest_compile_source_component
    subtest_run_source_component
  end
end

module SinkTest
  include SourceSubtests
  include SinkSubtests

  def test_sink
    subtest_check_source_preconditions
    subtest_generate_source_component
    subtest_generate_source_callbacks
    subtest_compile_source_component

    subtest_check_sink_preconditions
    subtest_generate_sink_component
    subtest_generate_sink_callbacks
    subtest_compile_sink_component
    subtest_run_source_sink_components
  end
end

module TestSourceBaseDetails
  # Generate a source with no messages.
  def subtest_generate_source_callbacks
    `ruby ./test/gen_source.rb -o #{btx_variables[:btx_component_path]}/callbacks.c`
    assert($?.success?)
  end

  # Compare with text.details in place of log.
  def subtest_run_source
    output = `babeltrace2 --plugin-path=#{btx_variables[:btx_component_path]} \
    --component=#{btx_variables[:btx_component_type].downcase}.#{btx_variables[:btx_pluggin_name]}.#{btx_variables[:btx_component_name]} \
    --component=sink.text.details`
    assert($?.success?)

    expected_output = File.open(btx_variables[:btx_target_log_path], 'r').read
    assert_equal(expected_output, output)
  end
end

module VariableAccessor
  attr_reader :btx_source_variables, :btx_sink_variables

  def shutdown
    FileUtils.remove_dir(@btx_source_variables[:btx_component_path], true) unless btx_source_variables.nil?
    FileUtils.remove_dir(@btx_sink_variables[:btx_component_path], true) unless btx_sink_variables.nil?
  end
end

module VariableClassAccessor
  def btx_source_variables
    self.class.btx_source_variables
  end

  def btx_sink_variables
    self.class.btx_sink_variables
  end
end
