require 'roadcrew/connection'

module Roadcrew
  module Client
    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :garage_client

      def inherited(child)
        child.instance_variable_set(:@garage_client, @garage_client)
        child.instance_variable_set(:@base_path, @base_path)
      end

      def garage(name)
        options = Roadcrew.configuration.garages[name.to_sym]
        @garage_client = Roadcrew::Connection.new(options)
      end

      def base_path(name = nil)
        if name.nil?
          @base_path ||= "/#{ self.name.tableize }"
        else
          @base_path = name
        end
      end

      def build_path(id = nil)
        return if base_path.nil?
        path = "#{ base_path }"
        path << "/#{ id }" unless id.nil?
        path
      end

      def modelize(response)
        case response
        when Array
          response.map { |res| new(res) }
        when Hash
          new(response)
        else
          nil
        end
      end

      def find(id)
        modelize(garage_client.get(build_path(id)))
      end

      def find_by(queries)
        modelize(garage_client.get(build_path, params: { q: queries }))
      end

      def all
        modelize(garage_client.get(build_path))
      end
    end

    def initialize(args = {})
      @params = {}
      if args.respond_to? :each
        args.each do |key, value|
          @params[key] = value
          self.class.module_eval do
            define_method(key) { @params[key] } unless method_defined?(key)
            define_method("#{ key }=") { |val| @params[key] = val } unless method_defined?("#{ key }=")
          end
        end
      end
    end

    def garage_client
      self.class.garage_client
    end

    def build_path(id = nil)
      self.class.build_path(id)
    end

    def update
      modelize(garage_client.patch(build_path(id), body: params))
    end

    def create
      modelize(garage_client.post(build_path, body: params))
    end

    def delete
      modelize(garage_client.delete(build_path(id)))
    end

    def params
      @params
    end

    def modelize(response)
      self.class.modelize(response)
    end
  end
end
