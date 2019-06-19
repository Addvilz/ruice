module Ruice
  class Dependency
    def initialize(target, is_fresh = false)
      @target = target
      @is_fresh = is_fresh
    end

    attr_reader :target, :is_fresh, :named
  end

  class Property
    def initialize(name, default = nil)
      @name = name
      @default = default
    end

    attr_reader :name, :default
  end

  class Container
    def initialize(properties = {}, env = 'default')
      raise ArgumentError, 'Container properties can not be nil' if properties.nil?
      raise ArgumentError, 'Container properties is not a Hash' unless properties.is_a? Hash
      raise ArgumentError, 'Environment can not be nil' if env.nil?
      raise ArgumentError, 'Environment must be a string' unless env.is_a? String

      properties[:env] = env

      @properties = properties
      @env = env.to_sym

      @bindings = {}
      @instances = {}
    end

    attr_reader :env

    def lookup_property(name, default = nil)
      path = name.split '.'
      current = @properties
      path.each do |key_part|
        break if current.nil?

        raise Exception, 'Can not access value subkey for non-hash ' + current unless current.is_a? Hash

        sym_part = key_part.to_sym

        current = current.fetch(sym_part, nil) || current.fetch(key_part, nil)
      end

      current || default
    end

    def request(name)
      return self if name == Ruice::Container

      return @instances[name] if @instances.key? name

      instance = request_new name

      @instances[name] = instance

      instance
    end

    def request_new(name)
      return self if name == Ruice::Container

      return @bindings[name].call self if @bindings.key? name

      raise ArgumentError, 'Dependency name is not class, and no bindings are present' unless name.respond_to? :new

      instance = name.new
      vars = instance.instance_variables

      vars.each do |it|
        value = instance.instance_variable_get it

        next unless value.is_a?(Dependency) || value.is_a?(Property)

        replacement = nil
        replacement = lookup_property value.name, value.default if value.is_a? Property

        if value.is_a? Dependency
          replacement = if value.is_fresh
                          request_new value.target
                        else
                          request value.target
                        end
        end

        instance.instance_variable_set it, replacement
      end

      instance.dic_ready if instance.methods.include? :dic_ready

      instance
    end

    def with(name, subject)
      if subject.is_a? Proc

        raise ArgumentError, 'Duplicate provider - ' + name if @bindings.key? name

        @bindings[name] = subject
        return
      end

      raise ArgumentError, 'Duplicate instance - ' + name if @instances.key? name

      @instances[name] = subject

      self
    end
  end
end
