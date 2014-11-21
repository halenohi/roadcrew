module Roadcrew
  module TestHelpers
    module ControllerHelper
      extend ActiveSupport::Concern

      def login
        @controller.session[Roadcrew::ControllerHelpers::SESSION_AUTH_KEY] = 'test auth'
        allow(@controller).to receive(:authenticate_admin_by_roadcrew!)
      end
    end
  end
end
