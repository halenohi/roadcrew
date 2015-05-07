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
      @expires_at = options[:expires_at]
      @refresh_token = options[:refresh_token]
    end

    def access_token
      @access_token ||= OAuth2::AccessToken.new(@oauth_client, @token, expires_at: @expires_at, refresh_token: @refresh_token)
    end

    def method_missing(method, *args)
      options = args[1]
      expires_in = options.try(:[], :cache_expires_in).presence || @cache_expires_in

      if REST_ACTIONS.include? method.to_s
        if defined_rails_cache? && expires_in.to_i > -1
          ::Rails.cache.fetch(cache_key(method, args), cache_options) do
            request_with_access_token(method, args)
          end
        else
          request_with_access_token(method, args)
        end
      else
        super
      end
    end

    def request_with_access_token(method, args)
      log(method, args)
      access_token.refresh! if access_token.expired?
      access_token.send(method, *args)
    rescue => e
    end

    private
      def cache_key(method, args)
        "Roadcrew_#{ @site }#{ args[0] }_#{ method }"
      end

      def cache_options
        { expires_in: cache_expires_in, skip_digest: true }
      end

      def log(*args)
        if defined_rails_logger?
          ::Rails.logger.info "[Roadcrew] ssl: #{ @ssl }, site: #{ @site }, args: #{ args[0..1] }"
        end
      end

      def defined_rails_logger?
        defined?(::Rails) && ::Rails.logger
      end

      def defined_rails_cache?
        defined?(::Rails) && ::Rails.cache
      end

      def mask_password(args)
        args.map{ |arg|
          if arg.is_a?(Hash)
            _mask_password_for_hash(arg)
          else
            arg
          end
        }
      end

      def _mask_password_for_hash(hash)
        hash.inject({}){ |res, (k, v)|
          if v.is_a?(Hash)
            v = _mask_password_for_hash(v)
          else
            v = '[FILTERD]' if k.to_s.include?('password')
          end
          res[k] = v
          res
        }
      end
  end
end
