Rails.application.routes.draw do
  resources :pages

  mount WorthSaving::Engine => "/worth_saving"
end
