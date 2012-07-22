require 'yaml'

module CouchbaseModelLogging

  class Logger

    attr_accessor :client, :prefix, :separator

    def initialize(client, prefix = nil, options = { })
      self.client    = client
      self.prefix    = prefix
      self.separator = options[:separator] || '[SEP]'
    end

    def key?(key)
      !get(key).nil?
    end

    def encode(hash)
      yaml = hash.to_yaml
      raise CouchbaseModelLogging::ReplacementError, "Found separator [#{separator}] in YAML string" if yaml.index(separator)
      yaml + separator
    end

    def add(key, hash = { })
      yaml     = encode hash
      pref_key = prefixed_key_for key
      begin
        client.append pref_key, yaml, :format => :plain
      rescue ::Couchbase::Error::NotStored
        client.add pref_key, yaml, :format => :plain
      end
    end

    def get(key)
      client.get(prefixed_key_for(key), :format => :plain)
    end

    def decode(str)
      return [] if str.nil? || str.empty?
      str.split(separator).map { |yaml| YAML.load yaml }
    end

    def all(key)
      decode get(key)
    end

    def prefixed_key_for(key)
      prefix.nil? ? key.to_s : "#{prefix}::#{key}"
    end

  end

end
