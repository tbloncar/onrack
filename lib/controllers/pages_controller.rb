class PagesController < AppController
  def index
    render({ 'greeting' => "Hello, world!" }, status: 200)
  end

  def about
    provide "About us!"
  end
end

