set :domain, 'sampler.wackwack.net'
set :application, "sampler"

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
set :rvm_ruby_string, '1.9.2'
set :rvm_type, :user

set :repository,  "git@github.com:quotto/Sampler.git"
set :deploy_to, "/var/www/sampler"


# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'master'
set :scm_verbose, true
set :use_sudo, false
set :rails_env, :production

namespace :deploy do
	desc "cause Passenger to initiate a restart"
	task :restart do
		run "touch #{current_path}/tmp/restart.txt"
	end
end

after "deploy:update_code", ;bundle_install
desc "install the necessary prequisites"
task :bundle_install, :roles => :app do
	run "cd #{release_path} && bundle install"
end
