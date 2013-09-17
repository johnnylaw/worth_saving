Rails.application.routes.draw do
  resources :pages

  get '/login/:id', to: 'login#login', as: :login
  get '/logout', to: 'login#logout', as: :logout

  mount WorthSaving::Engine => "/worth_saving"
end
