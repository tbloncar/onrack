class AppController
  attr_reader :request, :response

  def initialize(request, response)
    @request = request
    @response = response
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

