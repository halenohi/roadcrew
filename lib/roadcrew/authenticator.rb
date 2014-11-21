module Roadcrew
  module Authenticator
    class << self
      def authenticate!(auth = {})
        auth = {} if auth.nil?
        admin = admin_class.new(auth['token'])
        raise_error if auth['token'] == nil || !admin.logged_in?
      end

      def login!(credentials, &block)
        admin = admin_class.new
        token = admin.login(credentials)

        auth = token ? { 'token' => token } : false
        block.call(auth)

        raise_error unless auth
        auth
      end

      def logout(auth)
        admin_class.new(auth[:token]).logout
      end

      def raise_error
        raise Roadcrew::NotAuthenticatedError.new
      end

      def admin_class
        unless (@@admin_class_garagelized ||= false)
          Models::Admin.tap do |a|
            a.garage :admin
            a.base_path '/api'
          end
          @@admin_class_garagelized = true
        end
        Models::Admin
      end
    end
  end
end
