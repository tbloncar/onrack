require "rack"
require "rack/server"
require "liquid"

ROOTDIR = Dir.pwd
Dir.glob(ROOTDIR + "/lib/*.rb", &method(:require))
Dir.glob(ROOTDIR + "/lib/**/*.rb", &method(:require))
Dir.glob(ROOTDIR + "/app/*.rb", &method(:require))
Dir.glob(ROOTDIR + "/app/**/*.rb", &method(:require))

class OnRackApp
  def process_and_respond(env)
    request = Rack::Request.new(env)
    response = Rack::Response.new

    response = Router.new.route(request, response)
    response.finish
  end
end

class OnRack
  def self.call(env)
    OnRackApp.new.process_and_respond(env)
  end
end