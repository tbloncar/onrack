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
    if mapping = map_and_parameterize(request)
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

  class PathToRegexpStr
    attr_reader :path
    attr_accessor :regexp_str

    def initialize(path)
      @path = path
      @regexp_str = ""
      transform!
    end

    private

    def transform!
      rs = path.gsub(/:[^\/]*/, "[^\\/]*")
      rs.gsub!(/\w\//) { |match| match.gsub!("/", "\\/") }
      rs.gsub!(/\A\//, "\\/")
      rs.insert(0, "\\A").insert(-1, "\\z")
      @regexp_str = rs
    end
  end

  private

  def map_and_parameterize(request)
    rkey = "#{request.request_method.downcase}##{request.path}"
    if mapping = Router::routes[rkey] 
      return mapping
    end

    Router::routes.keys.each { |k|
      segmented_path = k.split("#")[1]
      regexp_str = PathToRegexpStr.new(segmented_path).regexp_str
      
      if Regexp.new(regexp_str).match(request.path)
        rkey = "#{request.request_method.downcase}##{segmented_path}"
        convert_dynamic_route_segments_to_params(request, segmented_path)
        return Router::routes[rkey]
      end
    }
    return false
  end

  def convert_dynamic_route_segments_to_params(request, segmented_path)
    request_path_segments = request.path.split("/")
    segmented_path.split("/").each_with_index { |segment, i|
      if /:.*/.match(segment)
        request[segment[1..-1]] = request_path_segments[i]     
      end
    }
  end

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

