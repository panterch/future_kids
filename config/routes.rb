FutureKids::Application.routes.draw do

  devise_for :users

  root :to => 'kids#index'
  resources :mentors
  resources :kids
  resources :teachers
  resources :journals

  match '/exception_test' => 'exception_test#error'
end
