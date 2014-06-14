class PagesController < AppController
  def index
    provide "You gotta hear this one song. It'll change your life, I swear."
  end

  def about
    provide "About us!", status: 200
  end
end

