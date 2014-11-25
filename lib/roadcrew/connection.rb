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
      options = args[1]
      if options.is_a?(Hash) && options[:cache_expires_in]
        cache_expires_in = options[:cache_expires_in]
      end

      if REST_ACTIONS.include? method.to_s
        if defined?(::Rails) && ::Rails.cache && cache_expires_in > -1
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
      access_token.send(method, *args)
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
