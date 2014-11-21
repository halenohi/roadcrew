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
        response = garage_client.get(build_path("/user_sessions/#{ @token }"), cache_expires_in: -1, raise_errors: false)
        response.status == 200
      end

      def login(credentials = {})
        response = garage_client.post(build_path('/user_sessions'), params: credentials, cache_expires_in: -1, raise_errors: false)
        if response.status == 201
          response.parsed['authentication_token']
        else
          false
        end
      end

      def logout
        response = garage_client.delete(build_path("/user_sessions/#{ @token }"), cache_expires_in: -1, raise_errors: false)
        response.status == 204
      end
    end
  end
end
