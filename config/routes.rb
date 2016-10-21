Rails.application.routes.draw do

  get "items/new" => "items#new", as: "new_item"
  get "items/:hashid/edit" => "items#edit", as: "edit_item"
  get "items(/:hashid)" => "items#index", as: "items"
  post "items" => "items#create"
  patch "items(/:hashid)/adopt" => "items#adopt", as: "adopt_item"
  patch "items/reorder" => "items#reorder", as: "reorder_items"
  patch "items/:hashid" => "items#update", as: "item"
  patch "items/:hashid/complete" => "items#complete", as: "complete_item"
  delete "items/:hashid" => "items#destroy"

  get "history(/:hashid)" => "items#history", as: "history"

  get "/auth/:provider/callback", to: "sessions#create"
  get "/bye" => "sessions#destroy", as: "sessions"

  get "/actions" => "actions#index", as: "actions"
  post "/actions/log" => "actions#log", as: "log_action"

  post "/feedback" => "feedback#create", as: "give_feedback"

  root "users#new"

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
