require 'test/unit'
require 'open3'

module Assertions
  def assert_file_exists(file_path)
    assert(File.file?(file_path), "File '#{file_path}' does not exists.")
  end

  def assert_command(cmd)
    _, stderr_str, exit_code = Open3.capture3(cmd)
    raise Exception, stderr_str unless exit_code == 0
  end

  def assert_command_stdout(cmd, expected_stdout)
    stdout_str, stderr_str, exit_code = Open3.capture3(cmd)
    raise Exception, stderr_str unless exit_code == 0

    assert_equal(expected_stdout, stdout_str)
  end

  def refute_command(cmd)
    _, stderr_str, exit_code = Open3.capture3(cmd)
    raise Exception, stderr_str if exit_code == 0
  end
end

def validate_file(d)
    [:btx_model_path, :btx_log_path].each { |file|
      assert_file_exists(d[file]) if d.key?(file)
    }
end

# def generate_component(d, component_type)
#     cmd = "ruby -I./lib ./bin/metababel -p #{d[:btx_pluggin_name]} -c #{d[:btx_component_name]} -o #{d[:btx_component_path]}"
#     cmd += " -i #{File.basename(d[:btx_usr_data_header_path])}" if d.key?(:btx_usr_data_header_path)
#     case component_type
#     when :SOURCE
#       cmd += " -d #{d[:btx_model_path]} -t SOURCE"
#     when :SINK
#       cmd += " -u #{d[:btx_model_path]} -t SINK"
#     end
# end

def get_component_generation_command(component_data)
  arguments = {
    btx_component_path: '-o %s ',
    btx_component_type: '-t %s ',
    btx_component_name: '-c %s ',
    btx_component_pluggin_name: '-p %s ',
    btx_component_downtream_model: '-d %s ',
    btx_component_upstream_model: '-u %s ',
    btx_component_user_header_file: '-i %s ',
  }

  command = 'ruby -I./lib ./bin/metababel '

  component_data.keys.grep(/_component_/) do |key|
    raise Exception("Unsupported component option '#{key}'") unless arguments.key?(key)
    command += arguments[key] % [ component_data[key] ]
  end

  command
end

def get_component_compilation_command(component)
  "${CC:-cc} -o #{component[:btx_component_path]}/#{component[:btx_pluggin_name]}_#{component[:btx_component_name]}.so #{component[:btx_component_path]}/*.c $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -Wall -Werror -fpic --shared -I ./test/include/"
end

def get_graph_execution_command(*components)
  components_paths = components.map { |c| c[:btx_component_path]  }
  components_graph = components.map { |c| "--component=#{c[:btx_component_type].downcase}.#{c[:btx_component_pluggin_name]}.#{c[:btx_component_name]}" }
  command = "babeltrace2 --plugin-path=#{components_paths.join(':')} #{components_graph.join(' ')}"
end

def copy_usr_files(component)
  component.keys.grep(/_file_/) do |key|
    assert_nothing_raised do
      FileUtils.cp(component[key], component[:btx_component_path])
    end
  end
end

def run_usr_commands(component)
  component.keys.grep(/_command_/) do |key|
    command = component[key] % component
    puts "run_usr_commands", command
    assert_command(command)
  end
end 

def generate_usr_files(d)
  # Callbacks
  # If user defined callbacks use it
  if d.key?(:btx_callbacks_path)
    assert_nothing_raised do
      FileUtils.cp(d[:btx_callbacks_path], d[:btx_component_path])
    end
  # Else we fall back to "gen_source" who use text-pretty log
  elsif d.key?(:btx_log_path)
      cmd = "ruby ./test/gen_source.rb -i #{d[:btx_log_path]} -o #{d[:btx_component_path]}/callbacks.c"
      cmd += " -y #{d[:btx_model_path]}" if d.key?(:btx_model_path)
      assert_command(cmd)
  end

  # Cast type header
  if d.key?(:btx_usr_data_header_path)
    assert_nothing_raised do
      FileUtils.cp(d[:btx_usr_data_header_path], d[:btx_component_path])
    end
  end
end

def compile_component(d)
  cmd = "${CC:-cc} -o #{d[:btx_component_path]}/#{d[:btx_pluggin_name]}_#{d[:btx_component_name]}.so #{d[:btx_component_path]}/*.c $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) $CFLAGS -Wall -Werror -fpic --shared -I ./test/include/"
  fct = d.fetch(:btx_compile_assertion_fct, :assert_command)
  send(fct, cmd)
end

module SourceSubtests
  include Assertions

  def subtest_run_source_component
    expected_output = File.open(btx_source_variables[:btx_log_path], 'r').read
    command = <<~TEXT
      babeltrace2 --plugin-path=#{btx_source_variables[:btx_component_path]} \
        --component=source.#{btx_source_variables[:btx_pluggin_name]}.#{btx_source_variables[:btx_component_name]}
    TEXT
    assert_command_stdout(command, expected_output)
  end
end

module SinkSubtests
  include Assertions

  def subtest_run_source_sink_components
    command = <<~TEXT
      babeltrace2 --plugin-path=#{btx_source_variables[:btx_component_path]}:#{btx_sink_variables[:btx_component_path]} \
        --component=source.#{btx_source_variables[:btx_pluggin_name]}.#{btx_source_variables[:btx_component_name]} \
        --component=sink.#{btx_sink_variables[:btx_pluggin_name]}.#{btx_sink_variables[:btx_component_name]}
    TEXT
    assert_command(command)
  end
end

module SourceDetailSubtests
  include Assertions

  # Compare with text.details in place of log.
  def subtest_run_source_component
    expected_output = File.open(btx_source_variables[:btx_log_details_path], 'r').read
    command = <<~TEXT
      babeltrace2 --plugin-path=#{btx_source_variables[:btx_component_path]} \
        --component=source.#{btx_source_variables[:btx_pluggin_name]}.#{btx_source_variables[:btx_component_name]} \
        --component=sink.text.details
    TEXT
    assert_command_stdout(command, expected_output)
  end
end

def pre_run(d,component_type)
    # Precondition
    validate_file(d)
    assert_command('ruby -I./lib ./bin/metababel -h')
    # Call Metababel
    assert_command(generate_component(d, component_type))
    # Mook user writting code
    generate_usr_files(d)
    # Compile
    compile_component(d)
end

module SourceTest
  include SourceSubtests

  def test_source
    # Precondition
    command_1 = get_component_generation_command(btx_source_variables)
    puts command_1
    assert_command(command_1)
    # # Copy user files 
    # copy_usr_files(btx_source_variables)
    # # Run user commands
    run_usr_commands(btx_source_variables)

    #Compile
    command_3 = get_component_compilation_command(btx_source_variables)
    assert_command(command_3)
    # Run
    command_2 = get_graph_execution_command(btx_source_variables)
    puts "command_2", command_2
    assert_command(command_2)
  end
end

module SinkTest
  include SourceSubtests
  include SinkSubtests

  def test_sink
    pre_run(btx_source_variables, :SOURCE) unless btx_source_variables.nil?
    pre_run(btx_sink_variables, :SINK)
    subtest_run_source_sink_components unless btx_source_variables.nil?
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
