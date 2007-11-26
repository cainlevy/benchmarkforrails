BenchmarkForRails.watch(:request, ActionController::Base, :process)

BenchmarkForRails.watch("respond_to block", ActionController::MimeResponds::InstanceMethods, :respond_to)
BenchmarkForRails.watch("activerecord find", ActiveRecord::Base, :find, false)
BenchmarkForRails.watch("before filters", ActionController::Filters::InstanceMethods, :run_before_filters)
BenchmarkForRails.watch("after filters", ActionController::Filters::InstanceMethods, :run_after_filters)
BenchmarkForRails.watch("session startup", CGI::Session, :initialize)
BenchmarkForRails.watch("rendering", ActionController::Base, :render)

class ActionController::Base
  # print reports at the end
  def process_with_benchmark_for_rails(*args, &block) #:nodoc:
    returning process_without_benchmark_for_rails(*args, &block) do
      BenchmarkForRails.report(self)
      logger.flush if logger.respond_to? :flush
    end
  end
  alias_method_chain :process, :benchmark_for_rails
end
