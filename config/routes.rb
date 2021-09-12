require 'sidekiq/web'

Rails.application.routes.draw do
  get 'profile', to: 'profile#index', as: 'profile'
  resources :forms, only: %i[ index show ]
  
  # Override default devise routes with routes to custom controllers
  Rails.application.routes.draw do
  get 'profile/index'
    devise_for :users, controllers: {
      registrations: 'users/registrations'
    }
  end

  resources :lessons, only: %i[ index ]

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
  mount Sidekiq::Web => '/sidekiq'

  get '/engage_scraper', to: 'engage_scraper#scrape', as: 'scrape_engage'
  get '/engage_scraper/authorise', to: 'engage_scraper#authorise', as: 'authorise_scrape_engage'
end
