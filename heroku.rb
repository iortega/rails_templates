require 'bundler'

# https://github.com/rails/rails/issues/3153
def bundle_install
  Bundler.with_clean_env do
    run "bundle install"
  end
end

# Gems
gem_group :production do
  gem 'rails_12factor'
end

bundle_install

# Labs
run "heroku labs:enable user-env-compile" 
run "heroku labs:enable http-request-id"
run "heroku labs:enable log-runtime-metrics"

# Addons

# Addon: PG Backups
run "heroku addons:add pgbackups:auto-month"
# Addon: Sendgrid
run "heroku addons:add sendgrid"
# Addon: Papertrail
# run "heroku addons:add papertrail"
# Addon: Logentries
run "heroku addons:add logentries"
# Addon: FlyData
run "heroku addons:add flydata"

# Addon: New Relic
gem 'newrelic_rpm'
bundle_install

run "curl https://gist.github.com/rwdaigle/2253296/raw/newrelic.yml > config/newrelic.yml"
run "heroku config:set NEW_RELIC_APP_NAME='#{app_name}'"
run "heroku addons:add newrelic"

# Addon: Memcachier
gem 'dalli'
bundle_install

environment nil, env: 'production' do
<<-CODE
config.cache_store = :dalli_store,
                    (ENV["MEMCACHIER_SERVERS"] || "").split(","),
                    {username: ENV["MEMCACHIER_USERNAME"],
                     password: ENV["MEMCACHIER_PASSWORD"],
                     failover: true,
                     socket_timeout: 1.5,
                     socket_failure_delay: 0.2
                    }
CODE
end
run "heroku addons:add memcachier"

# Unicorn
file 'config/unircorn.rb', <<-CODE
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
CODE

gem 'rack-timeout'
bundle_install

initializer 'timeout.rb', <<-CODE
Rack::Timeout.timeout = 10
CODE

file 'Procfile', <<-CODE
web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
CODE

git add: '.'
git commit: "-a -m'Heroku setup: unicorn, labs, addons: pgbackups, newrelic, sendgrid, logentries, flydata, memcachier'"