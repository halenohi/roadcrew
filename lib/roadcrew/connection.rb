module Roadcrew
  class Connection
    REST_ACTIONS = %w(get post put patch delete)

    def initialize(options)
      @client_id = options.delete(:client_id)
      @client_secret = options.delete(:client_secret)
      @site = options.delete(:endpoint)
      @token = options.delete(:access_token)
      @oauth_client = OAuth2::Client.new(@client_id, @client_secret, site: @site)
    end

    def access_token
      @access_token ||= OAuth2::AccessToken.new(@oauth_client, @token)
    end

    def method_missing(method, *args)
      if REST_ACTIONS.include? method.to_s
        access_token.send(method, *args).parsed
      else
        super
      end
    end
  end
end
