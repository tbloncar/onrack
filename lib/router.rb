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

  def route(request, response)
    rkey = "#{request.request_method.downcase}##{request.path}"
    if mapping = Router::routes[rkey]
      map_and_invoke_respond(mapping, request, response)
    else
      respond_to_absent_mapping(response)
    end
  end

  class Routes < Hash
    def add(verb, path, mapping)
      rkey = "#{verb}##{path}"
      self[rkey] = mapping
    end
  end

  private

  def map_and_invoke_respond(mapping, request, response)
    cstr, action = mapping.split("#")
    controller = Kernel.const_get("#{cstr.capitalize}Controller")
    controller.new(request, response).respond(action)
  end

  def respond_to_absent_mapping(response)
    response.status = 404
    response.write("Not Found")
    response
  end
end

