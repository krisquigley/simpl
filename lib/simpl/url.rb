require 'timeout'
require 'httparty'

class Simpl
  class Url
    include HTTParty
    base_uri 'https://www.googleapis.com'
  
    attr_accessor :url

    # required: url to be shortened
    def initialize(url, options = {})
      # sets the URL to be shortened
      self.url = url
      # allows an instance-level override for the api key
      @api_key = options[:api_key]
      # allows an instance-level override for the timeout
      @timeout = options[:timeout]
      # allows an instance-level override for the proxy
      @proxy = URI(options[:proxy]) if options[:proxy]
    end

    # Returns oauth authentication url, whereby the user can get their 'code'
    def authenticate_url
      "https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/urlshortener&response_type=code&client_id=#{ENV['GOOGL_CLIENT_ID']}&redirect_uri=#{ENV['GOOGL_REDIRECT_URI']}&access_type=offline&include_granted_scopes=true"
    end

    # Returns the access token and refresh_token in a hash
    def request_token
      request = { query: { code:          ENV['GOOGL_CODE'], 
                           client_id:     ENV['GOOGL_CLIENT_ID'], 
                           client_secret: ENV['GOOGL_CLIENT_SECRET'],
                           redirect_uri:  ENV['GOOGL_REDIRECT_URI'],
                           grant_type:    "authorization_code" } }

      result = self.class.post("/oauth2/v3/token", request)

      result.parsed_response
    end
  
    # returns: a string respresenting the shortened url
    # note: may be still the full url should a problem occur
    def shortened
      @shortened ||= shorten
    end
  
    private
    # processes the shortening of the full url
    def shorten
      request = {
          body:    { longUrl: url }.to_json,
          headers: { 'Content-Type' => 'application/json' },
          query:   { key: api_key, 
                     access_token: access_token }
        }

      request.merge!({  http_proxyaddr: proxy.host, 
                        http_proxyport: proxy.port, 
                        http_proxyuser: proxy.user, 
                        http_proxypass: proxy.password }) if proxy

      Timeout::timeout(timeout) do
        # submit the url to Goo.gl
        result = self.class.post("/urlshortener/v1/url", request)
        # return the response id or the url
        result.parsed_response["id"] || url
      end
    # if a problem occurs
    rescue Timeout::Error, JSON::ParserError => e
      # just return the original url
      url
    end

    # Generates a new access_token through the use of the refresh_token
    def access_token
      Rails.cache.fetch("googl_access_token", expires_in: 50.minutes) do 
        request = { query: { client_id:     ENV['GOOGL_CLIENT_ID'],
                             client_secret: ENV['GOOGL_CLIENT_SECRET'],
                             refresh_token: ENV['GOOGL_REFRESH_TOKEN'],
                             grant_type:    "refresh_token"} }

        result = self.class.post("/oauth2/v3/token", request)

        result.parsed_response["access_token"]
      end
    end

    def proxy
      @proxy || URI(ENV["QUOTAGUARDSTATIC_URL"])
    end
    
    def api_key
      @api_key || Simpl.api_key
    end

    def timeout
      @timeout || Simpl.timeout || 10
    end
  end
end