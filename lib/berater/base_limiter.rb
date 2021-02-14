module Berater
  class BaseLimiter

    attr_reader :options

    protected def initialize(**opts)
      @options = opts
    end

    def key
      if options[:key]
        "#{self.class}:#{options[:key]}"
      else
        # default value
        self.class.to_s
      end
    end

    def redis
      options[:redis] || Berater.redis
    end

    def limit(**opts)
      raise NotImplementedError
    end

  end
end
