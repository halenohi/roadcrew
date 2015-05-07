module Roadcrew
  module ClientProperty
    extend ActiveSupport::Concern

    class InvalidAttributes < StandardError; end

    included do
      @properties ||= {}
    end

    module ClassMethods
      def property(name, options = {})
        type = options[:type].to_s.classify || 'String'
        @properties[name.to_sym] = type
        module_eval do
          define_method("#{ name }") do
            self.class.type_cast @params[name.to_sym], type
          end unless method_defined?(name)
        end
      end

      def collection(name, options = {})
        type = options[:type].to_s.classify || 'String'
        @properties[name.to_sym] = type
        module_eval do
          define_method("#{ name }") do
            [@params[name.to_sym]].flatten.map do |value|
              self.class.type_cast value, type
            end
          end unless method_defined?(name)
        end
      end

      def properties
        @properties
      end

      def type_cast(value, type)
        method_name = "cast_as_#{ type.to_s.underscore }"
        if self.respond_to? method_name
          send method_name, value
        else
          type.constantize.new(value)
        end
      end

      def cast_as_string(value)
        value.to_s if value.respond_to? :to_s
      end

      def cast_as_integer(value)
        value.to_i if value.respond_to? :to_i
      end

      def cast_as_date(value)
        Date.parse value
      end

      def cast_as_date_time(value)
        DateTime.parse value
      end

      def cast_as_time(value)
        if defined?(::Rails)
          Time.zone.parse value
        else
          Time.parse value
        end
      end

      def cast_as_hash(value)
        case value
        when Hash
          value
        when Array
          Hash[value]
        end
      end

      def cast_as_array(value)
        if value.respond_to? :to_a
          value.to_a
        elsif value.present?
          [value]
        end
      end

      def cast_as_boolean(value)
        case value
        when 'true', '1'
          true
        when 'false', '0'
          false
        else
          !!value
        end
      end

      def cast_as_float(value)
        value.to_f if value.respond_to? :to_f
      end

      def cast_as_decimal(value)
        value.to_d if value.respond_to? :to_d
      end
    end

    def initialize(attrs = {})
      attrs = attrs.symbolize_keys
      raise Roadcrew::ClientProperty::InvalidAttributes unless is_valid?(attrs)

      @params = {}
      attrs.each do |key, value|
        @params[key] = type_cast value, key
        define_attribute_methods(key)
      end
    end

    def params
      @params
    end

    private
      def define_attribute_methods(key)
        self.class.module_eval do
          define_method(key) { @params[key.to_sym] } unless method_defined?(key)
          define_method("#{ key }=") { |val| @params[key.to_sym] = val } unless method_defined?("#{ key }=")
        end
      end

      def type_cast(value, key)
        if self.class.properties.has_key?(key.to_s)
          self.class.type_cast(value, self.class.properties[key.to_s])
        else
          value
        end
      end

      def is_valid?(attrs)
        attrs.is_a?(Hash) && (self.class.properties.keys - attrs.keys).empty?
      end
  end
end
