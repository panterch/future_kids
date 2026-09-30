# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :user, controllers: { sessions: 'users/sessions', passwords: 'users/passwords' }

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
      resources :comments, only: %w[new create edit update]
    end
    resources :reviews
    resources :first_year_assessments
    resources :termination_assessments
    resource :journal_summary, only: %i[create]
    member do
      get 'edit_schedules'
      get 'show_kid_mentors_schedules'
      patch 'show_kid_mentors_schedules'
      patch 'update_schedules'
    end
  end
  resources :kid_mentor_relations, except: :update do
    delete :destroy_all, on: :collection
    # inline editing of the exit kind/date of a kid or of a mentor
    collection do
      patch 'kids/:kid_id', action: :update_kid, as: :update_kid
      patch 'mentors/:mentor_id', action: :update_mentor, as: :update_mentor
    end
  end
  resources :schedules
  resources :schools
  resources :reminders
  resources :teachers
  resources :principals
  resource :site
  resource :terms_of_use, only: :show, controller: 'terms_of_use'

  get '/exception_test' => 'exception_test#error'
end
