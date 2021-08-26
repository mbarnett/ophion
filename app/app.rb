require 'rack'
require 'rack/contrib'
require 'sinatra'
require './app/util'
require './app/move'

use Rack::PostBodyContentTypeParser


APPEARANCE = {
  apiversion: "1",
  author: "",           # TODO: Your Battlesnake Username
  color: "#0FB6E9",
  head: "tongue",
  tail: "bolt",
}.freeze

def ok; 'OK'; end

before do
  @state = underscore(env['rack.request.form_hash'])
end

# routes
get '/' do
  respond APPEARANCE
end

post '/start' do
  ok
end

post '/move' do
  respond move(@state)
end

post '/end' do
  ok
end
