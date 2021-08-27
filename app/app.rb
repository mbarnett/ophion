require 'rack'
require 'rack/contrib'
require 'sinatra'
require './app/util'
require './app/ophion'

use Rack::JSONBodyParser

APPEARANCE = {
  apiversion: "1",
  author: "mbarnett",
  color: "#0FB6E9",
  head: "tongue",
  tail: "bolt",
}.freeze

def ok; 'OK'; end

before do
  @world_state = to_ruby_hash(env['rack.request.form_hash'])

  log "Request: #{request.path_info}"
  log "Game State: #{@world_state}"

  content_type :json
end

# routes
get '/' do
  respond APPEARANCE
end

post '/start' do
  ok
end

post '/move' do
  respond Ophion.choose_move(@world_state).to_h
end

post '/end' do
  ok
end
