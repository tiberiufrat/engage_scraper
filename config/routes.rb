require 'sidekiq/web'

Rails.application.routes.draw do
  resources :forms
  devise_for :users
  resources :lessons
  get 'timetable_scraper/scrape'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
  mount Sidekiq::Web => '/sidekiq'
  get '/scrape', to: 'timetable_scraper#scrape', as: 'scrape_timetable'
end
