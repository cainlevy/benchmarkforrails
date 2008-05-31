begin
  Dependencies.will_unload?(Array) # some already-loaded constant
rescue NameError
  # patch a typo bug in Dependencies
  Dependencies.module_eval do
    def will_unload?(const_desc)
      # this was autoloaded?(desc), which is an undefined variable
      autoloaded?(const_desc) ||
        explicitly_unloadable_constants.include?(to_constant_name(const_desc))
    end
  end
end