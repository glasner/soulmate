module Soulmate

  class Matcher < Base

    def matches_for_term(term, options = {})
      options = { :limit => 5, :cache => true }.merge(options)
      
      words = normalize(term).split(' ').reject do |w|
        w.size < MIN_COMPLETE or Soulmate.stop_words.include?(w)
      end.sort

      return [] if words.empty?

      cachekey = "#{cachebase}:#{words.join('|')}"

      cache(cachekey, words) if !options[:cache] || !redis.exists(cachekey)
      
      ids = redis.zrevrange(cachekey, 0, options[:limit] - 1)
      return [] if ids.empty?
      results = redis.hmget(database, *ids)
      results = results.reject{ |r| r.nil? } # handle cached results for ids which have since been deleted
      results.map { |r| MultiJson.decode(r) }
    end
    
    private
    
    # zinterstore command doesn't work with Redis::Namespace
    # so we have to manually namespace the keys for this call only
    def cache(key,words)
      interkeys = words.map { |word| namespaced("#{base}:#{word}")  }
      redis.zinterstore(namespaced(key), interkeys)
      redis.expire(key, 10 * 60) # expire after 10 minutes
    end
    
    def namespaced(key)
      return key unless redis.respond_to? :namespace
      "#{redis.namespace}:#{key}"
    end
    

  end
end 