set :application, "redmine"
set :repository,  "git@github.com:notch8/redmine.git"

set :scm, :git
set :deploy_to, "/var/www/apps/#{application}"

role :web, "notch8.com"                          # Your HTTP server, Apache/etc
role :app, "notch8.com"                          # This may be the same as your `Web` server
role :db,  "notch8.com", :primary => true # This is where Rails migrations will run

after 'deploy:finalize_update', 'deploy:symlink_database_config'
namespace :deploy do
  desc "Link to the shared database.yml."
  task :symlink_database_config, :roles => [:app] do
    run "rm -f #{latest_release}/config/database.yml"
    run "ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"

    run "rm -f #{latest_release}/config/email.yml"
    run "ln -nfs #{shared_path}/config/email.yml #{latest_release}/config/email.yml"

    run "rm -f #{latest_release}/config/initializers/session_store.rb"
    run "ln -nfs #{shared_path}/config/initializers/session_store.rb #{latest_release}/config/initializers/session_store.rb"
    
    run "rm -f #{latest_release}/repos"
    run "ln -nfs #{shared_path}/repos #{latest_release}/repos"
  end
  
  task :start do
  end
  task :stop do
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end