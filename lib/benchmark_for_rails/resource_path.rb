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
      @total_time ||= requests.collect{|r| r['request']}.sum
    end

    def average_time
      @average_time ||= total_time / frequency
    end

    def min
      @min ||= requests.collect{|r| r['request']}.min
    end

    def max
      @max ||= requests.collect{|r| r['request']}.max
    end

    def self.path_from(str)
      str.match(/\[(.*)\]/)[1]
    end
  end
end