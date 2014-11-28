module Roadcrew
  module Models
    class Admin
      include Client

      # garage :admin
      # base_path '/api'

      def initialize(token = nil)
        @token = token
      end

      def logged_in?
        return false if @token == nil
        response = request(:get, "/user_sessions/#{ @token }")
        response.status == 200
      end

      def login(credentials = {})
        response = request(:post, '/user_sessions', params: credentials)
        if response.status == 201
          response.parsed['authentication_token']
        else
          false
        end
      end

      def logout
        response = request(:delete, "/user_sessions/#{ @token }")
        response.status == 204
      end

      private
        def request_options
          {
            cache_expires_in: -1,
            raise_errors: false
          }
        end

        def request(verb, path, params = {})
          garage_client.send(verb, build_path(path), request_options.merge(params))
        end
    end
  end
end
