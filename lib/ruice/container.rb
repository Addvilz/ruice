# TODO:
# - named dependencies
# - dependency sets
# - ???
module Ruice
  class Dependency
    def initialize(target, require_new = false)
      @target = target
      @require_new = require_new
    end

    attr_reader :target
    attr_reader :require_new
  end

  class Container
    def initialize
      @bindings = {}
      @instances = {}
    end

    def request(target_class)
      return self if target_class == DIC::Container

      return @instances[target_class] if @instances.key? target_class

      instance = request_new target_class

      @instances[target_class] = instance

      instance
    end

    def request_new(target_class)
      return self if target_class == DIC::Container

      return @bindings[target_class].call self if @bindings.key? target_class

      instance = target_class.new
      vars = instance.instance_variables

      vars.each do |it|
        value = instance.instance_variable_get it

        next unless value.is_a? Dependency

        replacement = if value.require_new
                        request_new value.target
                      else
                        request value.target
                      end

        instance.instance_variable_set it, replacement
      end

      instance.dic_ready(self) if instance.methods.include? :dic_ready

      instance
    end

    def attach(name, provider)
      raise ArgumentError, 'Argument must be instance of Proc' unless provider.is_a? Proc

      @bindings[name] = provider
    end
  end
end
