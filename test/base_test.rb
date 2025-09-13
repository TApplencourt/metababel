require 'test/unit'
require 'open3'
require 'fileutils'

module Assertions
  def assert_file_exists(file_path)
    assert(File.file?(file_path), "File '#{file_path}' does not exists.")
  end

  def run_command(cmd, refute: false)
    puts(cmd) if ENV['METABABEL_VERBOSE']
    stdout_str, stderr_str, exit_code = Open3.capture3(cmd)
    # Sorry, it's a little too smart....
    assert((exit_code == 0) != refute, "cmd:#{cmd}\nstderr_str:#{stderr_str}")
    stdout_str
  end
end

def get_component_with_default_values(component)
  # We have only one component per plugins, the component name can be arbitrary.
  # TODO: We need to downcase for SOURCE -> source somewhere. They will need to be fixed later
  uuid = [component[:btx_component_type],
          component[:btx_component_label]].compact.map(&:downcase).join('_')

  { btx_component_name: 'component',
    btx_component_plugin_name: uuid,
    btx_component_path: "./test/#{uuid}",
    btx_compile: true }.update(component)
end

def get_component_generation_command(component)
  args = {
    btx_component_path: '-o',
    btx_component_type: '-t',
    btx_component_name: '-c',
    btx_component_params_model: '--params',
    btx_component_plugin_name: '-p',
    btx_component_downstream_model: '-d',
    btx_component_upstream_model: '-u',
    btx_component_usr_header_file: '-i',
    btx_component_callbacks: '-m',
    btx_component_enable_callbacks: '--enable_callbacks',
    btx_commonent_drop: '--drop',
  }
  str_ = component.filter_map { |k, v| "#{args[k]} #{[v].flatten.join(',')}" if args.key?(k) }.join(' ')

  if ENV['METABABEL_INSTALL']
    "metababel #{str_}"
  else
    "ruby -I./lib ./bin/metababel #{str_}"
  end
end

def get_component_compilation_command(component)
  uuid = %w[type plugin_name name].filter_map { |k| component[:"btx_component_#{k}"] }.join('_')
  uuid_so = "#{component[:btx_component_path]}/#{uuid}.so"
  "make -f ./test/Makefile BTX_SO_UUID=#{uuid_so} BTX_SRC=#{component[:btx_component_path]}"
end

def _get_plugin_path(components)
  components.map { |c| c[:btx_component_path] }.uniq
end

def _get_ctf_out_path(components)
  plugin_path = _get_plugin_path(components).first
  "#{plugin_path}/ctf_tmp"
end

def get_ctf_read_execution_command(components)
  command = ''
  if ENV['METABABEL_VALGRIND']
    command += <<~TEXT
      valgrind --suppressions=.valgrind/dlopen.supp
               --error-exitcode=1
               --leak-check=full
               --quiet
               --
    TEXT
  end

  ctf_out_path = _get_ctf_out_path(components)
  command += <<~TEXT
    babeltrace2 #{ctf_out_path}
  TEXT
  command.split.join(' ')
end

def get_graph_execution_command(components, connections, write_ctf=false)
  plugin_path = _get_plugin_path(components)
  components_list = components.map do |c|
    uuid = %w[type plugin_name name].map { |l| c[:"btx_component_#{l}"].downcase }.join('.')
    uuid_label = [c[:btx_component_label], uuid].compact.join(':')
    component_params = c.key?(:btx_component_params) ? "--params=#{c[:btx_component_params]}" : ''
    "--component=#{uuid_label} #{component_params}"
  end

  components_connections = connections.map { |c| "--connect=#{c}" }

  command = ''
  if ENV['METABABEL_VALGRIND']
    command += <<~TEXT
      valgrind --suppressions=.valgrind/dlopen.supp
               --error-exitcode=1
               --leak-check=full
               --quiet
               --
    TEXT
  end

  extra_args = ''
  if write_ctf
    ctf_out_path = _get_ctf_out_path(components)
    extra_args = "-o ctf -w #{ctf_out_path}"
  end

  command += <<~TEXT
    babeltrace2 --plugin-path=#{plugin_path.join(':')}
                #{'run' unless components_connections.empty?}
                #{components_list.join(' ')}
                #{components_connections.join(' ')}
                #{extra_args}
  TEXT
  command.split.join(' ')
end

def usr_assert_files(component)
  # Validate models
  component.keys.grep(/_model$/) do |key|
    [component[key]].flatten.each do |file_name|
      assert_file_exists(file_name)
    end
  end

  # Validate files
  component.keys.grep(/_file_/) do |key|
    assert_file_exists(component[key])
  end
end

def mock_user_callbacks(component)
  # See if we need to generate us callbacks.

  # If the user already define callbacks do nothing
  return if component.key?(:btx_file_usr_callbacks)

  # We support only generation of SOURCE callbacks
  return unless component[:btx_component_type] == 'SOURCE'

  assert(component.include?(:btx_component_downstream_model),
         'Need to provide :btx_component_downstream_model when generating callbacks for SOURCE')
  opt_log = component.key?(:btx_log_path) ? '-i %<btx_log_path>s' : ''
  command = "ruby ./bin/btx_gen_source_callbacks #{opt_log} -o %<btx_component_path>s/callbacks.c" % component
  run_command(command)
end

module GenericTest
  include Assertions

  def run_and_continue(command, component, key)
    if component.key?(key)
      run_command(command, refute: component[key])
      return false
    end
    run_command(command)
    true
  end

  def test_run
    # Provide components default values
    sanitized_components = btx_components.map { |c| get_component_with_default_values(c) }
                                         .filter do |c|
      next true unless c[:btx_compile]

      # Validate files
      usr_assert_files(c)
      # Generate Metababel
      next unless run_and_continue(get_component_generation_command(c),
                                   c, :btx_metababel_generation_fail)

      # Copy user files
      c.keys.grep(/_file_usr/) do |key|
        assert_nothing_raised do
          FileUtils.cp(c[key], c[:btx_component_path])
        end
      end
      # Mock user callbacks
      mock_user_callbacks(c)
      # Compile
      run_and_continue(get_component_compilation_command(c), c, :btx_compilation_should_fail)
    end
    return if sanitized_components.empty?

    has_sink = sanitized_components.join(' ').include?('sink')

    # Run the Graph
    stdout_str = run_command(get_graph_execution_command(sanitized_components, btx_connect))

    stdout_str_readctf = ''
    if not has_sink
      # Round trip through CTF format and back to pretty print
      run_command(get_graph_execution_command(sanitized_components, btx_connect, true))
      stdout_str_readctf = run_command(get_ctf_read_execution_command(sanitized_components))
    end

    # Output validation
    return unless btx_output_validation

    expected_output = File.read(btx_output_validation)
    assert_equal(expected_output, stdout_str)
    if not has_sink
      assert_equal(expected_output, stdout_str_readctf)
    end
  end
end

module VariableAccessor
  attr_reader :btx_components, :btx_output_validation, :btx_connect

  def shutdown
    # Sanitize provide default attributes such as btx_component_path if not provided by the user.
    @btx_components.map { |c| get_component_with_default_values(c) }.each do |c|
      FileUtils.remove_dir(c[:btx_component_path], true)
    end
  end
end

module VariableClassAccessor
  def btx_components
    self.class.btx_components
  end

  def btx_connect
    self.class.btx_connect || []
  end

  def btx_output_validation
    self.class.btx_output_validation
  end
end
