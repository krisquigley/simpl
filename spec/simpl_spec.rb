require "spec_helper"
require_relative "../lib/simpl"

describe Simpl do
  it "should allow specification of an API key" do
    Simpl.api_key = "123"
    Simpl.api_key.should == "123"
  end
  
  it "should allow specification of a timeout" do
    Simpl.timeout = 11
    Simpl.timeout.should == 11
  end
end