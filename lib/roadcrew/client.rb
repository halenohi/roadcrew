require 'roadcrew/connection'
require 'roadcrew/client_property'

module Roadcrew
  module Client
    extend ActiveSupport::Concern

    included do
      include Roadcrew::ClientProperty
    end

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
        path << '/' if id && !id.to_s.start_with?('/')
        path << "#{ id }" if id
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

    def modelize(response)
      self.class.modelize(response)
    end
  end
end
