require 'rake/testtask'

Dir.chdir(__dir__)

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/test_*.rb'
end

desc 'Run tests'
task default: :test
