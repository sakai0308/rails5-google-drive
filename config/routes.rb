Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'googledrive#index'
  get '/googledrive/get_docs', to: 'googledrive#get_docs'
end
