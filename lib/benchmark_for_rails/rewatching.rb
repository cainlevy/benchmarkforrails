module BenchmarkForRails
  class << self
    def rewatch!
      rewatchables.each do |(name, object_name, method, instance)|
        watch(name, object_name.constantize, method, instance)
      end
    end

    def rewatchable(*args)
      rewatchables << args unless rewatchables.include? args
    end

    private

    def rewatchables
      @rewatchables ||= []
    end
  end
end

# hook into dependency unloading
module ActiveSupport::Dependencies
  class << self
    def clear_with_rewatching(*args, &block)
      returning clear_without_rewatching(*args, &block) do
        BenchmarkForRails.rewatch!
      end
      alias_method_chain :clear, :rewatching
    end
  end
end

