class UsersController < AppController
  def index
    provide "You found users!"
  end

  def show
    provide "You found user ##{params['id']}! #{params.inspect}"
  end
end
