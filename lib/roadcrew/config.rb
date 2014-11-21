module Roadcrew
  def self.configure(&block)
    @config ||= Config.new(&block)
    @config.with(&block)
  end

  def self.configuration
    @config
  end

  class Config
    attr_reader :garages

    ATTR_NAMES = %w(
      view_layout_name
      after_logged_in_redirect_path_method
    ).freeze

    ATTR_NAMES.each do |attr_name|
      define_method attr_name do |value = nil|
        instance_variable_set("@#{ attr_name }", value) if value.present?
        instance_variable_get("@#{ attr_name }")
      end
    end

    def initialize
      @garages = Garages.new
    end

    def with(&block)
      instance_eval(&block)
    end

    def garage(hash)
      @garages.add hash
    end

    class Garages
      def initialize
        @collection = {}
      end

      def add(hash)
        key, options = hash.to_a[0]
        options = @collection[key].merge(options) if @collection[key]
        @collection[key] = options
      end

      def [](name)
        @collection[name]
      end
    end
  end
end
