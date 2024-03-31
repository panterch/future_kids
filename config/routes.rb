Rails.application.routes.draw do
  devise_for :user

  resources :self_registrations, { only: [:create, :new] } do
    collection do
      get 'success'
      get 'terms_of_use'
    end
  end

  root to: 'kids#index'
  resources :admins
  resources :documents
  resources :mentors do
    member do
      get 'edit_schedules'
      patch 'update_schedules'
      get 'disable_no_kids_reminder'
    end
  end
  resources :kids do
    resources :journals do
      resources :comments, only: %w(new create edit update)
    end
    resources :reviews
    resources :first_year_assessments
    resources :termination_assessments
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
  resources :available_kids
  resources :schedules
  resources :schools
  resources :reminders
  resources :teachers
  resources :principals
  resource :site
  resources :substitutions do
    member do
      put 'inactivate'
    end
  end
  resources :mentor_matchings do
    member do
      put :accept
      put :decline
      put :confirm
    end
  end

  get '/lehrpersonen', to: redirect('/self_registrations/new?type=teacher')
  get '/mentoren', to: redirect('/self_registrations/new?type=mentor')

  get '/exception_test' => 'exception_test#error'
end
