require File.dirname(__FILE__) + '/../lib/parsing.rb'
require File.dirname(__FILE__) + '/../lib/report.rb'

namespace :log do
  desc "run reports on BenchmarkForRails log output. examples: `rake log:analyze path='GET /'`, or `rake log:analyze order_by=averages`"
  task :analyze do
    report = BenchmarkForRails::Report.new
    order_by_totals = !(ENV['order_by'] =~ /^averages?/)
    BenchmarkForRails::LogParser.new.slowest(10, order_by_totals).each do |resource_path|
      report.rows << [resource_path.path, '%.4f' % resource_path.total_time, resource_path.frequency, '%.4f' % resource_path.average_time]
    end
    report.render('resource path', 'total time', 'frequency', 'average')
  end
end
