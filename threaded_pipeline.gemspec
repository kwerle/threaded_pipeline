lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'threaded_pipeline/version'

Gem::Specification.new do |spec|
  spec.name          = 'threaded_pipeline'
  spec.version       = ThreadedPipeline::VERSION
  spec.authors       = ['Kurt Werle']
  spec.email         = ['kurt@CircleW.org']

  spec.summary       = 'Run several stages of a pipeline in threads.'
  spec.description   = 'If you are eg. downloading a large file, processing that file, then writing the results to a database, ThreadedPipeline may be for you.  Download in one thread, process in another, and write in a third, etc.'
  spec.homepage      = 'https://github.com/kwerle/threaded_pipeline'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/kwerle/threaded_pipeline'
    spec.metadata['changelog_uri'] = 'https://github.com/kwerle/threaded_pipeline'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.glob('lib/**/*') + Dir.glob('LICENSE.txt')
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'byebug' unless ENV['JRUBY_VERSION']
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'guard-rubocop'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-color'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'yard'
end
