module Roadcrew
  class Engine < ::Rails::Engine
    initializer 'roadcrew.action_controller' do |app|
      ActiveSupport.on_load(:action_controller) do
        include Roadcrew::ControllerHelpers
      end
    end
  end
end
