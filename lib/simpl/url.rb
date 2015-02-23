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
          headers: { 'Content-Type' => 'application/json' }
          query:   { key: api_key }
        }

      request.merge!({  http_proxyaddr: proxy.host, 
                        http_proxyport: proxy.port, 
                        http_proxyuser: proxy.user, 
                        http_proxypass: proxy.password }) if proxy

      Timeout::timeout(timeout) do
        # submit the url to Goo.gl
        result = self.class.post("/urlshortener/v1/", request)
        # return the response id or the url
        result.parsed_response["id"] || url
      end
    # if a problem occurs
    rescue Timeout::Error, JSON::ParserError => e
      # just return the original url
      url
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