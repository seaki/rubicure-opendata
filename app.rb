require 'sinatra'
require 'slim'

configure do
  mime_type :ttl, 'text/turtle'
end

get '/' do
  slim :index
end
