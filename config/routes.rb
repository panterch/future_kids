Rails.application.routes.draw do
  devise_for :user

  root :to => 'kids#index'
  resources :admins
  resources :documents
  resources :mentors do
    member do
       get 'edit_schedules'
       patch 'update_schedules'
    end
  end
  resources :kids do
    resources :journals do
      resources :comments, only: ['new', 'create', 'update']
    end
    resources :reviews
    member do
       get 'edit_schedules'
       patch 'update_schedules'
    end
  end
  resources :schedules
  resources :schools
  resources :reminders
  resources :teachers
  resources :principals

  get '/exception_test' => 'exception_test#error'
end
