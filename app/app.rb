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
get '/' { respond APPEARANCE }

post '/start' { ok }

post '/move' { respond move(@state) }

post '/end' { ok }
