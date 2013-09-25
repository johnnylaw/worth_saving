Rails.application.routes.draw do
  resources :pages

  namespace :admin do
    resources :pages
  end

  get '/login/:id', to: 'login#login', as: :login
  get '/logout', to: 'login#logout', as: :logout

  mount WorthSaving::Engine => "/worth_saving"
end
