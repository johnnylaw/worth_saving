WorthSaving::Engine.routes.draw do
  resources :drafts, only: [:create, :update, :index]
end
