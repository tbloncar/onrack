require "rack"
require "rack/server"

class TheController
  attr_reader :request, :response

  def initialize(request, response)
    @request = request
    @response = response
  end

  def respond(action)
    send(action)
    response
  end
end

class PagesController < TheController
  def index
    response.write("Hello, world!")
    response.status = 200
  end

  def garden_state
    response.write("You gotta hear this one song. It'll change your life, I swear.")
  end
end

class Router
  class << self
    attr_accessor :routes
  end

  def self.routes
    @routes ||= Routes.new
  end

  def self.load
    yield(routes) 
  end

  class Routes < Hash
    def add(verb, path, mapping)
      rkey = "#{verb}##{path}"
      self[rkey] = mapping
    end
  end

  def route(request, response)
    rkey = "#{request.request_method.downcase}##{request.path}"
    if mapping = Router::routes[rkey]
      cstr, action = mapping.split("#")
      controller = Kernel.const_get("#{cstr.capitalize}Controller")
      controller.new(request, response).respond(action)
    else
      response.status = 404
      response.write("Not Found")
      response
    end
  end
end

Router.load do |routes|
  routes.add "get", "/", "pages#index"
  routes.add "get", "/gs", "pages#garden_state"
end

class Racker
  def response(env)
    request = Rack::Request.new(env)
    response = Rack::Response.new

    response = Router.new.route(request, response)
    response.finish
  end
end

class RackerApp
  def self.call(env)
    Racker.new.response(env)
  end
end

Rack::Server.start app: RackerApp