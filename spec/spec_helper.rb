require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/features/"
end

Dir[File.join(File.dirname(__FILE__), "support", "**/*.rb")].each {|f| require f}