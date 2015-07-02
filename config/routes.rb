Rails.application.routes.draw do
  devise_for :user

  root to: 'kids#index'
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
      resources :comments, only: %w(new create update)
    end
    resources :reviews
    member do
      get 'edit_schedules'
      get 'show_kid_mentors_schedules'
      patch 'show_kid_mentors_schedules'
      patch 'update_schedules'
    end
  end
  resources :kid_mentor_relations do
    delete :destroy_all, on: :collection
  end
  resources :schedules
  resources :schools
  resources :reminders
  resources :teachers
  resources :principals
  resource :site

  get '/exception_test' => 'exception_test#error'
end
