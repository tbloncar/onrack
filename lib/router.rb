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
    if mapping = find_mapping_and_decorate(request)
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

  def find_mapping_and_decorate(request)
    rkey = "#{request.request_method.downcase}##{request.path}"
    return m if m = Router::routes[rkey] 

    Router::routes.keys.each { |k|
      path = k.split("#")[1]
     
      regexp_str = path.gsub(/:[^\/]*/, "[^\\/]*")
      regexp_str.gsub!(/\w\//) { |match|
        match.gsub!("/", "\\/") 
      }
      regexp_str.gsub!(/\A\//, "\\/")
      regexp_str.insert(0, "\\A")
      regexp_str.insert(-1, "\\z")

      if Regexp.new(regexp_str).match(request.path)
        rkey = "#{request.request_method.downcase}##{path}"

        request_path_segments = request.path.split("/")
        path.split("/").each_with_index { |segment, i|
          if /:.*/.match(segment)
            request[segment[1..-1]] = request_path_segments[i]     
          end
        }

        return Router::routes[rkey]
      end
    }

    return nil
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

