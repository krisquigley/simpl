# Simpl is a Googl URL shortener

The API is simple:

    your_url = "http://example.com/"
    your_api_key = "1234567890abcedf"    
    Simpl::Url.new(your_url, api_key: your_api_key).shortened
    # -> http://goo.gl/123
    
If you're using Rails, it's probably best to setup an initializer with your key in it:

    # config/initializers/simpl.rb
    Simpl.api_key = "1234567890abcedf"
    
    # then use the API like this:
    Simpl::Url.new(your_url).shortened

# Testing

To test the project on your local machine, download it, run `bundle install`, then run `rake`.

# License

Please see [LICENSE](https://github.com/PlatformQ/simpl/blob/master/LICENSE)