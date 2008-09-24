# ####################
# base config
# ####################
set :application, "cspot"
set :deploy_to, "/var/www/#{application}"

# ####################
# code repository
# ####################
default_run_options[:pty] = true
set :scm, :git
set :repository,  "git@github.com:mwhitt/copyrightspot.git"
set :branch, "master"
set :scm_passphrase, "qwerty89"
set :deploy_via, :remote_cache

# ####################
# account management
# ####################
set :user, "matt"
ssh_options[:port] = 420

# ####################
# server config
# ####################
role :app, "copyrightspot.com"
role :web, "copyrightspot.com"
role :db,  "copyrightspot.com", :primary => true

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
 
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end