Rails.application.routes.draw do

  get "items/new" => "items#new", as: "new_item"
  get "items/:id/edit" => "items#edit", as: "edit_item"
  get "items(/:parent_id)" => "items#index", as: "items"
  post "items" => "items#create"
  patch "items/:id" => "items#update", as: "item"
  delete "items/:id" => "items#destroy"

  get "/auth/:provider/callback", to: "sessions#create"
  delete "/bye" => "sessions#destroy", as: "sessions"

  root "users#new"

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
