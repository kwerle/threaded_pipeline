$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'threaded_pipeline'

require 'minitest/autorun'

require 'minitest/color'

begin
  require 'byebug'
rescue LoadError
  puts 'We are probably in jruby or some other non-byebug platform.'
end
