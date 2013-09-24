WorthSaving::Engine.routes.draw do
  resources :drafts, only: [:create, :update, :index]

  WorthSaving::Engine.config.additional_namespaces.each do |space|
    namespace space do
      resources :drafts, only: [:create, :update, :index]
    end
  end
end
