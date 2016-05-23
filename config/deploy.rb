set :application, 'futurekids'
set :repo_url, 'git@github.com:panterch/future_kids.git'

set :linked_files, fetch(:linked_files, []).push('config/secrets.yml')
set :linked_dirs, fetch(:linked_dirs, []).push('public/system')
