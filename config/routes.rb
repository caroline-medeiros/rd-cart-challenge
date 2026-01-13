require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  resources :products

  get "up" => "rails/health#show", as: :rails_health_check
  root "rails/health#show"

  get    '/cart',             to: 'carts#show',        defaults: { format: :json }
  post   '/cart',             to: 'carts#add_item',    defaults: { format: :json }
  post   '/cart/add_item',    to: 'carts#add_item',    defaults: { format: :json }, as: :add_item_cart
  delete '/cart/:product_id', to: 'carts#remove_item', defaults: { format: :json }
end
