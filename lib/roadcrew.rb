require "rails"
require "oauth2/client"
require "oauth2/access_token"

require "roadcrew/authenticator"
require "roadcrew/test_helpers/controller_helper"
require "roadcrew/config"
require "roadcrew/client"
require "roadcrew/connection"
require "roadcrew/controller_helpers"
require "roadcrew/engine"
require "roadcrew/models/admin"
require_relative "../config/endpoints"

module Roadcrew
  class NotAuthenticatedError < StandardError; end
end
