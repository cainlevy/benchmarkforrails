# Bleh. Why isn't this already loaded? I need Symbol#& !
require 'active_support'
# Huh. It's as though autoloading doesn't work for rake tasks.
require File.dirname(__FILE__) + '/../lib/benchmark_for_rails'
require File.dirname(__FILE__) + '/../lib/benchmark_for_rails/report'
require File.dirname(__FILE__) + '/../lib/benchmark_for_rails/log_parser'
require File.dirname(__FILE__) + '/../lib/benchmark_for_rails/resource_path'

namespace :log do
  desc "run reports on BenchmarkForRails log output. examples: `rake log:analyze path='GET /'`, or `rake log:analyze order_by=averages`"
  task :analyze do
r=Benchmark.measure{
    report = BenchmarkForRails::Report.new
    order_by_totals = !(ENV['order_by'] =~ /^averages?/)
    BenchmarkForRails::LogParser.new.slowest(10, order_by_totals).each do |resource_path|
      report.rows << [
        resource_path.path,
        '%.4f' % resource_path.total_time,
        resource_path.frequency,
        '%.4f' % resource_path.average_time,
        "#{'%.3f' % resource_path.min} - #{'%.3f' % resource_path.max}"
      ]
    end
    report.render('resource path', 'total time', 'frequency', 'average', 'min - max')
}.real
p r
  end
end
