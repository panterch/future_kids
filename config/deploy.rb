require 'bundler/capistrano'

set :application, "futurekids"
server 'futurekids.panter.ch', :app, :web, :db, :primary => true


set :rails_env, 'production'

set :deploy_via, :remote_cache
set :scm, :git
set :default_run_options, { :pty => true }
set :repository, "git@github.com:panter/future_kids.git"
set :ssh_options, {:forward_agent => true}
set :deploy_to, "/home/rails/app"
set :user, "rails"
set :use_sudo, false

after "deploy", "deploy:cleanup"

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

task :update_config_links, :roles => [:app] do
  run "ln -sf #{shared_path}/config/* #{release_path}/config/"
end
after "deploy:update_code", :update_config_links

