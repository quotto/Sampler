
set :application, 'sampler'
set :repo_url, 'git@github.com:quotto/Sampler.git'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, '/var/www/sampler'
set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

#set :rvm_base_path, "/usr/local/rvm"
set :rvm_ruby_version, "ruby-1.9.3-p448"
#set :rvm_rb_path, "#{fetch :rvm_base_path}/gems/#{fetch :rvm_rb_version}"
#set :default_env, {
#  path: "#{fetch :rvm_rb_path}/bin:#{fetch :rvm_rb_path}@global/bin:#{fetch :rvm_base_path}/rubies/#{fetch :rvm_rb_version}/bin:$PATH"
#}

namespace :deploy do  
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
       execute :touch, "#{fetch :deploy_to}/tmp/restart.txt"
    end
  end
end