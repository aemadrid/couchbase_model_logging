require 'couchbase'

module CouchbaseModelLogging

  class Client

    attr_accessor :host, :port, :pool, :bucket, :protocol, :username, :password

    def initialize(options = { })
      self.protocol = options[:protocol] || 'http'
      self.host     = options[:host] || 'localhost'
      self.port     = options[:port] || 8091
      self.pool     = options[:pool] || 'default'
      self.bucket   = options[:bucket] || 'default'
      self.username = options[:username]
      self.password = options[:password]
    end

    def url
      "#{protocol}://#{host}:#{port}/pools/#{pool}/buckets/#{bucket}"
    end

    def connection_options
      (username && password) ? { :username => username, :password => password } : {}
    end

    def native_client
      @native_client ||= ::Couchbase.connect url, connection_options
    end

    def respond_to?(meth)
      native_client.respond_to?(meth) || super
    end

    def method_missing(meth, *args, &blk)
      if native_client.respond_to? meth
        call_info = caller[0] =~ /\/([\w\.]+):(\d+):in `(\w+)'/ ? "#{$1}:#{$2} #{$3}" : "unknown"
        #puts "mm : #{meth} : #{args.inspect} | from #{call_info}"
        native_client.send meth, *args, &blk
      else
        super
      end
    end

    alias_method :decorator_methods, :methods

    def methods
      (decorator_methods + native_client.methods).uniq
    end

  end

end