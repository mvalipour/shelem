require 'datadog/statsd'

STATSD = Datadog::Statsd.new(
  'localhost',
  8125,
  tags: ['env:%s' % ENV['RAILS_ENV']]
)
