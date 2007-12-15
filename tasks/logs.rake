require File.dirname(__FILE__) + '/../lib/parsing.rb'
require File.dirname(__FILE__) + '/../lib/report.rb'

namespace :log do
  namespace :analyze do

    desc 'reports the slowest actions, based on average time'
    task 'averages' do
      report = BenchmarkForRails::Report.new
      BenchmarkForRails::LogParser.new.slowest(10, false).each do |resource_path|
        report.rows << [resource_path.path, '%.4f' % resource_path.total_time, resource_path.frequency, '%.4f' % resource_path.average_time]
      end
      report.render('resource path', 'total time', 'frequency', 'average')
    end

    desc 'reports the slowest actions, based on total time'
    task 'totals' do
      report = BenchmarkForRails::Report.new
      BenchmarkForRails::LogParser.new.slowest(10, true).each do |resource_path|
        report.rows << [resource_path.path, '%.4f' % resource_path.total_time, resource_path.frequency, '%.4f' % resource_path.average_time]
      end
      report.render('resource path', 'total time', 'frequency', 'average')
    end

#     desc 'reports the benchmarks for a certain resource path'
#     task 'resource_path' do
#       # todo
#     end
  end
end
