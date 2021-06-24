# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'checks#dashboard'
  resources :checks do
    get 'job', to: 'checks#job'
    get 'jobs/recreate', to: 'checks#jobs_recreate', on: :collection
    get 'admin', to: 'checks#admin', on: :collection
    get 'load-from-file', to: 'checks#load_from_file', on: :collection
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
