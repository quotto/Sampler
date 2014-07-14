
set :application, 'sampler'
set :repo_url, 'git@github.com:quotto/Sampler.git'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, '/var/www/project/sampler'
set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

set :rbenv_ruby,'2.1.2'

set :default_env, {
  rbenv_root: "#{fetch(:rbenv_path)}",
  path: "#{fetch :rbenv_path}/shims:#{fetch :rbenv_path}/bin:$PATH"
}

set :bundle_without, [:development]

namespace :deploy do  
  desc 'Delete assets'
  task :clear_assets do
    on roles(:app),in: :sequence, wait: 5 do
      execute :rm, "-rf shared/public/assets"
    end
  end
  after :starting, :clear_assets
    
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, "#{fetch :deploy_to}/current/tmp/restart.txt"
    end
  end

  after :publishing, :restart
end
