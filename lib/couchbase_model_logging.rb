libdir      = File.dirname(__FILE__)
full_libdir = File.expand_path(libdir)
$LOAD_PATH.unshift(full_libdir) unless $LOAD_PATH.include?(libdir) || $LOAD_PATH.include?(full_libdir)

require 'couchbase_model_logging/exceptions'
require 'couchbase_model_logging/client'
require 'couchbase_model_logging/logger'