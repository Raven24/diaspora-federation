module DiasporaFederation
  # Provides a simple DSL for specifying {Entity} properties during class
  # definition.
  # @see Entity.define_props
  class PropertiesDSL
    # This is where the DSL block gets evaluated.
    # Call {PropertiesDSL#properties} on the created instance after you're
    # done defining the properties to get an array of properties in order they
    # were specified.
    # @param [Proc] block will be evaluated in the created instance

    attr_accessor :properties, :defaults

    def initialize(&block)
      @properties = []
      @defaults = {}
      instance_eval(&block)
      @properties.freeze
      @defaults.freeze
    end

    # Define a generic (string-type) property
    # @param [Symbol] name property name
    # @param [Hash] opts further options
    # @option opts [Object, #call] :default a default value, making the
    #   property optional
    def property(name, opts = {})
      define_property name, String, opts
    end

    # Define a property that should contain another Entity or an array of
    # other Entities
    # @param [Symbol] name property name
    # @param [Entity, Array<Entity>] type Entity subclass or
    #                Array with exactly one Entity subclass constant inside
    # @param [Hash] opts further options
    # @option opts [Object, #call] :default a default value, making the
    #   property optional
    def entity(name, type, opts = {})
      fail InvalidType unless type_valid?(type)

      define_property name, type, opts
    end

    protected

    def define_property(name, type, opts = {})
      fail InvalidName unless name_valid?(name)

      @properties << { name: name, type: type }
      @defaults[name] = opts[:default] if opts.key? :default
    end

    def name_valid?(name)
      (name.instance_of?(Symbol) ||
       name.instance_of?(String))
    end

    def type_valid?(types)
      [types].flatten.all? do |type|
        type.respond_to?(:ancestors) && type.ancestors.include?(Entity)
      end
    end

    # Raised, if the name is of an unexpected type
    class InvalidName < RuntimeError
    end

    # Raised, if the type is of an unexpected type
    class InvalidType < RuntimeError
    end
  end
end
