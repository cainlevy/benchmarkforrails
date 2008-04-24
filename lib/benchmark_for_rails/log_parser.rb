module BenchmarkForRails
  class LogParser
    # The log file to be read.
    attr_accessor :file

    # If set to a Time, will limit the parsed responses to those *after*
    # the threshold. This lets you parse the last hour's worth of data out
    # of a log.
    #
    # Depends on the 'elif' gem.
    attr_accessor :threshold

    def initialize(file = nil, threshold = nil)
      self.file = file || RAILS_ROOT + '/log/production.log'
      self.threshold = threshold
    end

    # pulls B4R lines out of the logfile.
    B4R_RE        = /^B4R/
    PROCESSING_RE = /\AProcessing .+ at (\d+-\d+-\d+ \d+:\d+:\d+)\Z/
    def lines
      if @lines.nil?
        if threshold
          require 'elif'
          @lines = []
          Elif.foreach(self.file) do |line|
            if B4R_RE.match(line)
              @lines << line
            elsif threshold and PROCESSING_RE.match(line)
              @lines.pop and break if Time.parse($1) < self.threshold
            end
          end
        else
          @lines ||= File.read(self.file).grep(/^B4R/)
        end
      end
      @lines
    end

    # reads the resource_paths to calculate average times for *each* benchmark type.
    # that is, this returns averages indexed by benchmark, not path.
    def benchmarks
      if @benchmarks.nil?
        benchmarks = {}
        resource_paths.each do |path|
          path.requests.each do |request|
            request.each do |benchmark, time| (benchmarks[benchmark] ||= []) << time end
          end
        end

        @benchmarks = {}
        benchmarks.each do |benchmark, times| @benchmarks[benchmark] = (times.sum || 0) / times.size end
      end
      @benchmarks
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
    # pre-generate the regular expressions. this matters when you loop one million times.
    PATH_STRIP_RE         = /.*\] */
    MEASUREMENT_SPLIT_RE  = / *: */
    PATH_RE               = /\[(.*?)\]/

    attr_reader :path
    attr_reader :requests

    def initialize(path)
      @path = path
      @requests = []
    end

    def add_request(line)
      measurements = {}
      line.sub(PATH_STRIP_RE, '').split(' | ').each do |measurement|
        md = MEASUREMENT_SPLIT_RE.match(measurement)
        measurements[md.pre_match] = md.post_match.to_f
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
      PATH_RE.match(str)[1]
    end
  end
end