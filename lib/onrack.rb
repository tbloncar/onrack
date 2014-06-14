project_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(project_root + "/controllers/*", &method(:require))

require "rack"
require "rack/server"
require_relative "router"
require_relative "routes"

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

Rack::Server.start app: OnRack