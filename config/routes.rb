FutureKids::Application.routes.draw do

  devise_for :users

  root :to => 'mentors#index'
  resources :mentors
  resources :kids

  match '/exception_test' => 'exception_test#error'
end
