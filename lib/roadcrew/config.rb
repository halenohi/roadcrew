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
        options = hash.to_a[0]
        @collection.store(options[0], options[1])
      end

      def [](name)
        @collection[name]
      end
    end
  end
end
