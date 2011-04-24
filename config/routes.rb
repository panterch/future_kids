FutureKids::Application.routes.draw do

  devise_for :users

  root :to => 'posts#index'
  resources :posts
  resources :mentors

  match '/exception_test' => 'exception_test#error'
end
