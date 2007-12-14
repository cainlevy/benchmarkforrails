require File.dirname(__FILE__) + '/../lib/parsing.rb'

namespace :log do
  desc 'reports the slowest actions, based on average time'
  task 'slowest_average_times' do
    BenchmarkForRails::LogParser.new.slowest(10, false).each do |resource_path|
      puts "[#{resource_path.path.ljust(40, ' ')}] #{'%.4f' % resource_path.average_time} seconds (#{resource_path.frequency} requests)"
    end
  end

  desc 'reports the slowest actions, based on total time'
  task 'slowest_total_times' do
    BenchmarkForRails::LogParser.new.slowest(10, true).each do |resource_path|
      puts "[#{resource_path.path.ljust(40, ' ')}] #{'%.4f' % resource_path.total_time} seconds (#{resource_path.frequency} requests)"
    end
  end
end
