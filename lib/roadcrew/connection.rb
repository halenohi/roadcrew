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
          Rails.cache.fetch(cache_key, cache_options) do
            log(method, args)
            access_token.send(method, *args)
          end
        else
          log(method, args)
          access_token.send(method, *args)
        end
      else
        super
      end
    end

    private
      def cache_key(method, args)
        "Roadcrew_#{ @site }#{ args[0] }_#{ method }"
      end

      def cache_options
        { expires_in: cache_expires_in, skip_digest: true }
      end

      def log(*args)
        if defined? ::Rails
          ::Rails.logger.info "[Roadcrew] ssl: #{ @ssl }, site: #{ @site }, args: #{ args.map(&:inspect) }"
        end
      end
  end
end
