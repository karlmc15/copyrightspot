#############################################################
#  Application
#############################################################
 
set :application, "cspot"
set :deploy_to, "/var/www/#{application}"
 
#############################################################
#  Settings
#############################################################
 
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :use_sudo, true
set :scm_verbose, true 
 
#############################################################
#  Servers
#############################################################
 
set :user, "matt"
ssh_options[:port] = 420
set :domain, "copyrightspot.com"
server domain, :app, :web
role :db, domain, :primary => true
 
#############################################################
#  Git
#############################################################
 
set :scm, :git
set :branch, "master"
set :scm_user, 'matt'
set :scm_passphrase, "qwerty89"
set :repository, "git@github.com:mwhitt/copyrightspot.git"
set :deploy_via, :remote_cache
 
#############################################################
#  Passenger
#############################################################
 
namespace :deploy do
  
  # Restart passenger on deploy
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
  
  namespace :web do
    
    desc "Custom deploy:web:disable task"
    task :disable, :roles => :web, :except => { :no_release => true } do
      require 'erb'
      on_rollback { run "rm #{shared_path}/system/maintenance.html" }

      reason = ENV['REASON']
      deadline = ENV['UNTIL']

      template =    File.read("./app/views/layouts/maintenance.rhtml")
      result =    ERB.new(template).result(binding)

      put result,     "#{shared_path}/system/maintenance.html", :mode => 0644
    end
    
    desc "Custom deploy:web:enable task"
    task :enable, :roles => :web, :except => { :no_release => true } do
      run "rm #{shared_path}/system/maintenance.html"
    end
    
  end
  
end
