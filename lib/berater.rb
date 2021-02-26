require 'berater/limiter'
require 'berater/lock'
require 'berater/lua_script'
require 'berater/utils'
require 'berater/version'

module Berater
  extend self

  class Overloaded < StandardError; end

  attr_accessor :redis

  def configure
    yield self
  end

  def new(key, capacity, interval = nil, **opts)
    case capacity
    when :unlimited, Float::INFINITY
      Berater::Unlimiter
    when :inhibited, 0
      Berater::Inhibitor
    else
      if interval
        Berater::RateLimiter
      else
        Berater::ConcurrencyLimiter
      end
    end.yield_self do |klass|
      args = [ key, capacity, interval ].compact
      klass.new(*args, **opts)
    end
  end

  def register(mode, klass)
    MODES[mode.to_sym] = klass
  end

  def expunge
    redis.scan_each(match: "#{self.name}*") do |key|
      redis.del key
    end
  end

end

# convenience method
def Berater(key, capacity, interval = nil, **opts, &block)
  Berater.new(key, capacity, interval, **opts).limit(&block)
end

# load limiters
require 'berater/concurrency_limiter'
require 'berater/inhibitor'
require 'berater/rate_limiter'
require 'berater/unlimiter'
