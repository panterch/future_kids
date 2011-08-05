FutureKids::Application.routes.draw do

  devise_for :users

  root :to => 'kids#index'
  resources :admins
  resources :mentors
  resources :kids do
    resources :journals
    resources :reviews
  end
  resources :schedules
  resources :reminders
  resources :teachers

  match '/exception_test' => 'exception_test#error'
end
