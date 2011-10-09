require 'redis'

module Ramaze
  class Cache
    class Redis
      include Cache::API

      OPTIONS = {
        :expires_in => 604800,
        :host => 'localhost',
        :port => 6379,
      }

      def initialize(options = {})
        @options = OPTIONS.merge(options)
      end

      def cache_setup(hostname, username, appname, cachename)
        options[:namespace] = [
          hostname, username, appname, cachename
        ].compact.join('-')
        
        @client = ::Redis.new(options)
      end

      def cache_clear
        raise NotImplmentedError, 'Please contribute, if you know how to clear'
      end

      def cache_delete(*keys)
        @client.del(*keys)
      end

      def cache_fetch(key, default = nil)
        value = @client.get(key)
        value.nil? ? default : value
      end

      def cache_store(key, value, ttl = nil, options = {})
        ttl = options[:ttl] || @options[:expires_in]
        @client.setex(key, ttl, value)
        value
      end
    end
  end
end
