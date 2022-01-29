require 'byebug'
require File.expand_path '../spec_helper.rb', __FILE__

describe "rubicure-opendata Application" do
  it "should allow accessing the home page" do
    get '/'
    expect(last_response).to be_ok
  end

  it "should allow accessing the sparql endpoint with GET" do
    get '/sparql'
    expect(last_response).to be_ok
  end

  it "should allow accessing the sparql endpoint with POST" do
    post '/sparql'
    expect(last_response).to be_ok
  end

  it "should return Turtle when negotiated" do
    header 'Accept', 'text/turtle'
    get '/sparql', :query => 'SELECT ?s ?p ?o WHERE {?s ?p ?o.}'
    expect(last_response).to be_ok
    # byebug
  end
end
