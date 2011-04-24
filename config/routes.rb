FutureKids::Application.routes.draw do

  root :to => 'posts#index'
  resources :posts

  match '/exception_test' => 'exception_test#error'
end
