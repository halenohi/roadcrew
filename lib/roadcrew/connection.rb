module Roadcrew
  class Connection
    REST_ACTIONS = %w(get post put patch delete)

    attr_accessor :cache_expires_in

    def initialize(options)
      @client_id = options[:client_id]
      @client_secret = options[:client_secret]
      @site = options[:endpoint]
      @token = options[:access_token]
      @ssl = options[:ssl] || { verify: true }
      @oauth_client = OAuth2::Client.new(@client_id, @client_secret, site: @site, ssl: @ssl)
      @cache_expires_in = options[:cache_expires_in] || 1.hours
    end

    def access_token
      @access_token ||= OAuth2::AccessToken.new(@oauth_client, @token)
    end

    def method_missing(method, *args)
      if REST_ACTIONS.include? method.to_s
        if Rails.cache
          Rails.cache.fetch "Roadcrew_#{ @site }#{ args[0] }_#{ method }", expires_in: cache_expires_in, skip_digest: true do
            access_token.send(method, *args)
          end
        else
          access_token.send(method, *args)
        end
      else
        super
      end
    end
  end
end
