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
module ActiveSupport
  module Dependencies
    class << self
      def clear_with_rewatching(*args, &block)
        returning clear_without_rewatching(*args, &block) do
          BenchmarkForRails.rewatch!
        end
      end
      alias_method_chain :clear, :rewatching
    end
  end
end
# patch a typo bug in Dependencies
begin
  ActiveSupport::Dependencies.will_unload?(Array) # some already-loaded constant
rescue NameError
  ActiveSupport::Dependencies.module_eval do
    def will_unload?(const_desc)
      # this was autoloaded?(desc), which is an undefined variable
      autoloaded?(const_desc) ||
        explicitly_unloadable_constants.include?(to_constant_name(const_desc))
    end
  end
end