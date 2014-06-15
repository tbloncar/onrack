class AppController
  attr_reader :request, :response, :params

  def initialize(request, response)
    @request = request
    @response = response
    @params = request.params
  end

  def respond(action)
    send(action)
    response
  end

  class ViewRenderer
    attr_reader :dirname, :viewname, :vars

    def initialize(dirname, viewname, vars)
      @dirname = dirname
      @viewname = viewname
      @vars = vars
    end

    def render
      view = Liquid::Template.parse(view_content).render(vars)
      Liquid::Template.parse(layout_content).render("view" => view)
    end

    private

    def layout_content
      layout_path = "#{ROOTDIR}/app/views/layouts/layout.liquid"
      File.open(layout_path, "r").read
    end

    def view_content
      view_path = "#{ROOTDIR}/app/views/#{dirname}/#{viewname}.liquid"
      File.open(view_path, "r").read
    end
  end

  private

  def render(vars = {}, status: 200)
    viewname  = caller_locations(1,1)[0].label
    dirname   = self.class.to_s.gsub("Controller", "").downcase
    view      = ViewRenderer.new(dirname, viewname, vars).render

    response.write(view)
    response.status = status
  end
end
