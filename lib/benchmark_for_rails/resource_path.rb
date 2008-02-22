module BenchmarkForRails
  class ResourcePath
    attr_reader :path
    attr_reader :requests

    def initialize(path)
      @path = path
      @requests = []
    end

    def add_request(line)
      measurements = {}
      line.sub(/.*\]/, '').split(' | ').each do |measurement|
        name, seconds = *measurement.split(':').collect{|p| p.strip}
        measurements[name] = seconds.to_f
      end
      self.requests << measurements
    end

    def frequency
      @frequency ||= requests.length
    end

    def total_time
      @total_time ||= self['request'].sum
    end

    def average_time
      @average_time ||= total_time / frequency
    end

    def min
      @min ||= self['request'].min
    end

    def max
      @max ||= self['request'].max
    end

    def self.path_from(str)
      str.match(/\[(.*)\]/)[1]
    end

    def [](benchmark_name)
      requests.collect{|r| r[benchmark_name.to_s]}
    end
  end
end