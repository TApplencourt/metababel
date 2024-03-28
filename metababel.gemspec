require File.expand_path('lib/metababel/version', __dir__)

Gem::Specification.new do |s|
  s.name = 'metababel'
  s.authors	= ['Thomas Applencourt', 'Aurelio A. Vivas Meza', 'Brice Videau']
  s.summary     = 'Helper for creation Babeltrace plugins'
  s.version     = Metababel::VERSION
  s.files       = Dir['{lib}/**/*.rb', 'template/*.erb', 'bin/*', 'LICENSE', '*.md', 'shared/*.cpp']
  s.license     = 'MIT'
  s.executables = ['metababel', 'btx_gen_source_callbacks']
  s.metadata['rubygems_mfa_required'] = 'true'
end
