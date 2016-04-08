Rails.application.routes.draw do

  get "items/new" => "items#new", as: "new_item"
  get "items/:id/edit" => "items#edit", as: "edit_item"
  get "items(/:id)" => "items#index", as: "items"
  post "items" => "items#create"
  patch "items/reorder" => "items#reorder", as: "reorder_items"
  patch "items(/:id)/clear" => "items#clear", as: "clear_items"
  patch "items/:id" => "items#update", as: "item"
  patch "items/:id/complete" => "items#complete", as: "complete_item"
  patch "items/:id/adopt" => "items#adopt", as: "adopt_item"
  delete "items/:id" => "items#destroy"

  get "/auth/:provider/callback", to: "sessions#create"
  delete "/bye" => "sessions#destroy", as: "sessions"

  root "users#new"

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
