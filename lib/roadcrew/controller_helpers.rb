module Roadcrew
  module ControllerHelpers
    extend ActiveSupport::Concern

    SESSION_AUTH_KEY = 'roadcrew:auth'

    included do
      rescue_from Roadcrew::NotAuthenticatedError do
        not_authenticated
      end

      helper_method :roadcrew_admin?
    end

    private
      def roadcrew_auth
        session[SESSION_AUTH_KEY]
      end

      def roadcrew_admin?
        !!roadcrew_auth
      end

      def authenticate_admin_by_roadcrew!
        Roadcrew::Authenticator.authenticate!(roadcrew_auth)
      end

      def login(credentials)
        Roadcrew::Authenticator.login!(credentials) do |auth|
          session[SESSION_AUTH_KEY] = auth if auth
        end
      end

      def logout
        Roadcrew::Authenticator.logout(roadcrew_auth)
        not_authenticated
      end

      def not_authenticated
        session.delete(SESSION_AUTH_KEY)
        redirect_to defined?(login_path) ? login_path : '/'
      end
  end
end
