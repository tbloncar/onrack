class PagesController < AppController
  def index
    render({ 'greeting' => "Hello, world!" }, status: 200)
  end
end

