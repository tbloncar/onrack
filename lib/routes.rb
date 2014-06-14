Router.load do |routes|
  routes.add "get", "/", "pages#index"
  routes.add "get", "/about", "pages#about"
end

