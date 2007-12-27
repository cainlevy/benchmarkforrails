module BenchmarkForRails
  class LogParser
    attr_accessor :file
    def initialize
      self.file = RAILS_ROOT + '/log/production.log'
    end

    # pulls B4R lines out of the logfile
    def lines
      @lines ||= File.read(self.file).grep(/^B4R/)
    end

    # pulls ResourcePath objects out of the file
    def resource_paths
      if @resource_paths.nil?
        paths_by_path = {}
        lines.each do |line|
          path_name = ResourcePath.path_from(line)
          paths_by_path[path_name] ||= ResourcePath.new(path_name)
          paths_by_path[path_name].add_request(line)
        end
        @resource_paths = paths_by_path.values
      end
      @resource_paths
    end

    # returns the slowest few ResourcePaths
    # optionally determines slowness by weighting speed vs frequency (e.g. total time, not average time)
    def slowest(number = 10, total_time = false)
      resource_paths.sort_by(&(total_time ? :total_time : :average_time)).reverse[0...number]
    end
  end

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

    def self.path_from(str)
      str.match(/\[(.*)\]/)[1]
    end
  end
end