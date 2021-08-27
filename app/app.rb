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

Config = Struct.new(:health_hunger_threshold,
                    :length_hunger_threshold,
                    :minimum_search_threshold,
                    :max_search_depth)

def ok; 'OK'; end

configure do
  set :config, Config.new(ENV['HEALTH_HUNGER_THRESHOLD'].to_i,
                          ENV['LENGTH_HUNGER_THRESHOLD'].to_i,
                          ENV['MINIMUM_SEARCH_THRESHOLD'].to_i,
                          ENV['MAXIMUM_SEARCH_DEPTH'].to_i)
end

before do
  @world_state = to_ruby_hash(env['rack.request.form_hash'])

  log "Request: #{request.path_info}"

  content_type :json
end

get '/' do
  respond APPEARANCE
end

post '/start' do
  ok
end

post '/move' do
  respond Ophion.new(settings.config).choose_move(@world_state).to_h
end

post '/end' do
  ok
end
