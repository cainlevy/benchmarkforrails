# BenchmarkForRails addresses a few issues with ActionController's benchmarking:
# * hidden query costs (ActiveRecord's cost of building a query)
# * no visibility on the cost of before/after filters
# * no visibility on cost of session management
#
# Other strengths:
# * very easy to benchmark new things without implementing your own alias_method_chain (use BenchmarkForRails.watch)
# * automatically handles methods called multiple times (e.g. ActiveRecord::Base#find)
module BenchmarkForRails
  class << self
    # Starts benchmarking for some method. Results will be automatically
    # logged after the request finishes processing.
    #
    # Arguments:
    # * name: how to refer to this benchmark in the logs
    # * obj: the object that defines the method
    # * method: the name of the method to be benchmarked
    # * instance: whether the method is an instance method or not
    def watch(name, obj, method, instance = true)
      results[name] ||= 0

      obj.class_eval <<-EOL
        #{"class << self" unless instance}
        def #{method}_with_better_benchmarks(*args, &block)
          BenchmarkForRails.measure(#{name.inspect}) {#{method}_without_better_benchmarks(*args, &block)}
        end

        alias_method_chain :#{method}, :better_benchmarks
        #{"end" unless instance}
      EOL
    end

    def results #:nodoc:
      @results ||= {}
    end

    # Used by watch to record the time of a method call without losing the
    # method's return value
    def measure(name, &block)
      result = nil
      self.results[name] += Benchmark.measure{result = yield}.real
      result
    end

    # Prints the benchmarks for the request into the log, with some
    # basic ASCII formatting (yay).
    def report(controller)
      logger.info "-- [#{controller.request.method.to_s.upcase}] #{controller.controller_class_name}\##{controller.action_name} ".ljust(40, '-')

      results.to_a.sort_by{|(name, seconds)| seconds}.reverse.each do |(name, seconds)|
        logger.info "  #{'%.4f' % seconds} #{name}"
      end

      logger.info " BenchmarkForRails --".rjust(40, '-')

      results.clear
    end

    def logger #:nodoc:
      RAILS_DEFAULT_LOGGER
    end
  end
end
