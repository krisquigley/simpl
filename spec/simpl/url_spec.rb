require "json"
require "spec_helper"
require_relative "../../lib/simpl"

describe Simpl::Url do
  let(:url) { "http://example.com/test-page" }
  let(:actual_api_key) { "1234567890abcdef" }
  
  before do
    Simpl.api_key = actual_api_key
    Simpl.timeout = 30
  end
  
  subject { Simpl::Url.new(url) }
  
  context "when no custom timeout is set" do
    let(:timeout) { 123 }
    
    before(:each) { Simpl.timeout = timeout }
    
    it "should return the timeout set on the Simpl class" do
      subject.send(:timeout).should == timeout
    end
  end
  
  context "when setting a custom timeout" do
    let(:timeout) { 654 }
    
    subject { Simpl::Url.new(url, timeout: timeout) }
    
    it "should return the custom timeout" do
      subject.send(:timeout).should == timeout
    end
  end
  
  context "when no timeout is set on the class or instance" do
    before(:each) { Simpl.timeout = nil }
    
    it "should return 10 seconds as the default timeout" do
      subject.send(:timeout).should == 10
    end
  end
  
  context "when no custom API key is set" do
    let(:api_key) { "hello" }
    
    before(:each) do
      Simpl.api_key = api_key
    end
    
    it "should return the API key set on the Simpl class" do
      subject.send(:api_key).should == api_key
    end
  end
  
  context "when setting a custom API key" do
    let(:api_key) { "0987654321" }
    
    subject { Simpl::Url.new(url, api_key: api_key) }
    
    it "should return the custom API key" do
      subject.send(:api_key).should == api_key
    end
  end
  
  context "when no API key is set on the class or instance" do
    before(:each) { Simpl.api_key = nil }
    
    it "should raise an error" do
      lambda { subject.send(:api_key) }.should raise_error(Simpl::NoApiKeyError)
    end
  end
  
  context "when invalid data is returned from the API" do
    before(:each) do
      response = mock("response", body: "<html><head></head><body></body></html>")
      Simpl::Url.should_receive(:post).and_return(response)
    end
    
    it "should return the original URL" do
      subject.shortened.should == url
    end
  end
  
  context "when the API times out" do
    before(:each) do
      Simpl::Url.should_receive(:post).and_raise(Timeout::Error)
    end
    
    it "should return the original URL" do
      subject.shortened.should == url
    end
  end
  
  context "when the API returns valid JSON with an id" do
    let(:shortened_url) { "http://goo.gl/123" }
    
    before(:each) do
      response = mock("response", body: { id: shortened_url }.to_json)
      Simpl::Url.should_receive(:post).and_return(response)
    end

    it "should return a valid shortened URL" do
      subject.shortened.should == shortened_url
    end
  end
  
  context "when the API returns valid JSON without an ID" do
    before(:each) do
      response = mock("response", body: {}.to_json)
      Simpl::Url.should_receive(:post).and_return(response)
    end
    
    it "should return the original URL" do
      subject.shortened.should == url
    end
  end
  
  context "against the real API" do
    use_vcr_cassette "googl-valid-submission"
    
    let(:actual_api_key) do
      api_key_file = File.join(File.dirname(__FILE__), "../../", "API_KEY")
      unless File.exist?(api_key_file)
        raise StandardError, %Q(
          You haven't specified your Googl API key in ./API_KEY,
          to obtain your's go here:
          https://code.google.com/apis/console/
        )
      end
      File.read(api_key_file)
    end

    it "should store a valid full URL" do
      subject.url.should == url
    end
    
    it "should shorten the url" do
      subject.shortened.should =~ /^http\:\/\/goo.gl\/.*$/
    end
  end
end