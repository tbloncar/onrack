Router.load do |routes|
  routes.add "get", "/", "pages#index"

  routes.add "get", "/users", "users#index"
  routes.add "get", "/users/:id", "users#show"
end

