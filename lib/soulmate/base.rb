module Soulmate
  
  class Base
    
    include Helpers
    
    attr_accessor :type,:redis
    
    def initialize(type,opt={})
      @type = normalize(type)
      @redis = opt[:redis] || Soulmate.redis
    end
    
    def base
      "soulmate-index:#{type}"
    end

    def database
      "soulmate-data:#{type}"
    end

    def cachebase
      "soulmate-cache:#{type}"
    end
  end
end