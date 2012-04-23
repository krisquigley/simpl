require "simpl/version"
require "simpl/url"

class Simpl
  class << self
    # your API key to access Goo.gl
    # get your's at: https://code.google.com/apis/console/
    attr_writer :api_key
    
    def api_key
      @api_key || (raise NoApiKeyError, %Q(
        No Goo.gl API key is present, please set one using:
        # if you're using Rails put this in config/initializers/googl.rb
        Googl.api_key = 'YOUR_KEY_HERE'
      ))
    end
    
    # how long to wait for Goo.gl response
    # default: 10
    attr_accessor :timeout
  end
  
  class NoApiKeyError < StandardError; end
end
