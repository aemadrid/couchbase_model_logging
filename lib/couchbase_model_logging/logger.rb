require 'yaml'

module CouchbaseModelLogging

  class Logger

    attr_accessor :client, :prefix, :string_separator, :key_separator

    def initialize(client, prefix = nil, options = { })
      self.client    = client
      self.prefix    = prefix
      self.key_separator = ":"
      self.string_separator = options[:string_separator] || '[SEP]'
    end

    def key?(key)
      !get(key).nil?
    end

    def encode(hash)
      yaml = hash.to_yaml
      raise CouchbaseModelLogging::ReplacementError, "Found separator [#{string_separator}] in YAML string" if yaml.index(string_separator)
      yaml + string_separator
    end

    def add(key, hash = { })
      yaml     = encode hash
      pref_key = prefixed_key_for key
      begin
        client.append pref_key, yaml, :format => :plain
      rescue ::Couchbase::Error::NotStored
        begin
          client.add pref_key, yaml, :format => :plain
        rescue ::Couchbase::Error::KeyExists
          client.append pref_key, yaml, :format => :plain
        end
      end
    end

    def get(key)
      client.get(prefixed_key_for(key), :format => :plain)
    end

    def decode(str)
      return [] if str.nil? || str.empty?
      str.split(string_separator).map { |yaml| YAML.load yaml }
    end

    def all(key)
      decode get(key)
    end

    def delete(key)
      client.delete prefixed_key_for(key)
    end

    def prefixed_key_for(key)
      prefix.nil? ? key.to_s : "#{prefix}#{key_separator}#{key}"
    end

  end

end
