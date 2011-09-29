require 'bundler/capistrano'
require 'capistrano/ext/multistage'

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

set :application, "futurekids"
set :rails_env, 'production'

set :deploy_via, :remote_cache
set :scm, :git
set :default_run_options, { :pty => true }
set :repository, "git@github.com:panter/future_kids.git"
set :ssh_options, {:forward_agent => true}
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

