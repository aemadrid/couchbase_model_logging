unless const_defined?(:SPEC_HELPER_LOADED)
  require 'rubygems'
  require 'bundler'
  begin
    Bundler.setup(:default, :development)
  rescue Bundler::BundlerError => e
    $stderr.puts e.message
    $stderr.puts "Run `bundle install` to install missing gems"
    exit e.status_code
  end
  require 'minitest/autorun'

  $LOAD_PATH.unshift(File.dirname(__FILE__))
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
  require 'couchbase_model_logging'

  SPEC_HELPER_LOADED = true
end