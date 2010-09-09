# The indentation of this benchmark tree indicates which benchmarks include which other benchmarks.
# For example, :request = :reloading + :dispatch + ?
# And, :dispatch = :routing + :process + ?
BenchmarkForRails.watch(:request, ActionController::Dispatcher, :call)
  BenchmarkForRails.watch("reloading", ActionController::Dispatcher, :reload_application, false) if RAILS_ENV == 'development'
  # this runs after all the middleware
  BenchmarkForRails.watch('dispatch', ActionController::Dispatcher, :_call)
    BenchmarkForRails.watch('routing', ActionController::Routing::RouteSet, :recognize)
    BenchmarkForRails.watch('process', ActionController::Base, :process)
      BenchmarkForRails.watch("filters", ActionController::Filters::BeforeFilter, :call)
      # Processing the action itself (calling the controller method)
      # This is what Rails' default benchmarks claim is the response time.
      BenchmarkForRails.watch("action", ActionController::Base, :perform_action)
        # And yes, it's still important to know how much time is spent rendering.
        BenchmarkForRails.watch("rendering", ActionController::Base, :render)
      BenchmarkForRails.watch("filters", ActionController::Filters::AfterFilter, :call)
  # TODO: this happens at the *end* of a request, after the middleware stack and definitely
  # after reporting. so these times get attributed to the *next* request. too confusing.
  # BenchmarkForRails.watch("reloading", ActionController::Dispatcher, :cleanup_application, false) if RAILS_ENV == 'development'

# The real cost of database access should include query construction.
# Hence why we try and watch the core finder. More watches might be added
# to this group to form a more complete picture of database access. The
# question is simply which methods bypass find().
# TODO: disabling this until it can be more comprehensive.
# BenchmarkForRails.watch("queries", ActiveRecord::Base, :find, false)
# BenchmarkForRails.watch("queries", ActiveRecord::Base, :find_by_sql, false)

# Should be included after the BenchmarkForRails.watch(:request, ...),
# since it hooks into the same method.
require 'reporting'
