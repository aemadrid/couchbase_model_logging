module CouchbaseModelLogging

  class Logger

    attr_accessor :client, :prefix, :separator, :replacement

    def initialize(client, prefix, options = { })
      self.client      = client
      self.prefix   = prefix
      self.separator   = options[:separator] || '[SEP]'
      self.replacement = options[:replacement] || '[SEP_REPL]'
    end

    def add(key, hash = {})
      json = hash.to_json
      raise CouchbaseModelLogging::ReplacementError, "Found replacement [#{replacement}] in JSON string" if hash.index(replacement)
      json = json.gsub separator, replacement
      prefixed_key = "#{prefix}::#{key}"
      begin
        client.add prefixed_key, json, :format => "plain"
      rescue ::Couchbase::Error::KeyExists
        client.append prefixed_key, json, :format => "plain"
      end
    end

    def all(key)
      prefixed_key = "#{prefix}::#{key}"
      client.get prefixed_key
    end

  end

end
