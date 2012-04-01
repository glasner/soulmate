module Soulmate

  class Matcher < Base

    def matches_for_term(term, options = {})
      redis = options.delete(:redis) || Soulmate.redis
      options = { :limit => 5, :cache => true }.merge(options)
      
      words = normalize(term).split(' ').reject do |w|
        w.size < MIN_COMPLETE or Soulmate.stop_words.include?(w)
      end.sort
      
      puts "Check for #{words.inspect}"

      return [] if words.empty?
      
      puts 'Past words.empty'

      cachekey = "#{cachebase}:" + words.join('|')

      if !options[:cache] || !redis.exists(cachekey)
        interkeys = words.map { |w| "#{base}:#{w}" }
        redis.zinterstore(cachekey, interkeys)
        redis.expire(cachekey, 10 * 60) # expire after 10 minutes
      end

      ids = redis.zrevrange(cachekey, 0, options[:limit] - 1)
      if ids.size > 0
        results = redis.hmget(database, *ids)
        results = results.reject{ |r| r.nil? } # handle cached results for ids which have since been deleted
        results.map { |r| MultiJson.decode(r) }
      else
        puts "no ids found #{ids.inspect}"
        []
      end
    end
  end
end 