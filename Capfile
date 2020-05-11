# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
require "capistrano/rbenv"
require "capistrano/bundler"
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'whenever/capistrano'

namespace :load do
  task :defaults do
    # Setup capistrano
    set :user, 'app'
    set :deploy_to, -> { "/home/#{ fetch(:user) }/app" }
    set :ssh_options, -> { { user: fetch(:user), forward_agent: true } }
    set :log_level, :info

    set :linked_files, %w[ config/database.yml ]
    set :linked_dirs, %w[ log tmp/cache tmp/pids tmp/sockets ]

    # Setup capistrano-rails
    set :rails_env, 'production'

    # Setup capistrano-rbenv
    set :rbenv_type, :user
    set :rbenv_ruby, open("#{ Bundler.root }/.ruby-version").read.strip

  end
end

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
