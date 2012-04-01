require 'uri'
require 'multi_json'
require 'redis'

require 'soulmate/version'
require 'soulmate/helpers'
require 'soulmate/base'
require 'soulmate/matcher'
require 'soulmate/loader'

module Soulmate

  extend self

  MIN_COMPLETE = 2
  DEFAULT_STOP_WORDS = ["vs", "at", "the"]

  def redis=(connection)
    return @redis = connection if connection.is_a? Redis
    @redis = nil
    @redis_url = connection
    d
  end

  def redis
    @redis ||= (
      url = URI(@redis_url || ENV["REDIS_URL"] || "redis://127.0.0.1:6379/0")

      ::Redis.new({
        :host => url.host,
        :port => url.port,
        :db => url.path[1..-1],
        :password => url.password
      })
    )
  end

  def stop_words
    @stop_words ||= DEFAULT_STOP_WORDS
  end

  def stop_words=(arr)
    @stop_words = Array(arr).flatten
  end
  
  ## Shortcut Methods
  
  def loader
    @loader ||= Loader.new
  end
  
  def add(item,opt={})
    loader.add item,opt
  end
  
  def remove(item)
    loader.remove item
  end
  
  def matcher
    @matcher ||= Matcher.new
  end
  
  def matches_for_term(term,opt={})
    matcher.matches_for_term term,opt
  end

end
