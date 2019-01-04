require 'redis'

REDIS_CLIENT = Redis.new(url: ENV['REDISCLOUD_URL'])
