# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "checks#dashboard"
  resources :checks do
    get "job", to: "checks#job"
    # Actions with side effects are POST: the admin page's buttons are forms,
    # which Turbo does not prefetch on hover like links
    post "check", to: "checks#check_all", on: :collection
    post "tls/check", to: "checks#tls_check_all", on: :collection
    post "notifications/test", to: "checks#notifications_test", on: :collection
    get "admin", to: "checks#admin", on: :collection
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
