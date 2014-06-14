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

  private

  def provide(content, status: 200, options: {})
    response.write(content)
    response.status = status
  end
end

