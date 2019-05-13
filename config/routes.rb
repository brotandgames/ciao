Rails.application.routes.draw do
  root to: 'checks#dashboard'
  resources :checks do
    get '/job', to: 'checks#job'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
