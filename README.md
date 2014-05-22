# Rails 4 Templates

Collection of my most used rails apps templates recipes.


## Usage

Using [Rails Apps Composer](https://github.com/RailsApps/rails_apps_composer):

    gem install rails_apps_composer

### Rails 3

    rails_apps_composer new <app_name> -q -d rac_defaults.yml

### Rails 4

    rails_apps_composer new <app_name> -q -d rac_rails4_defaults.yml
  

## Rails Templates

Apply a new template to an existing rails project:

    rake rails:template LOCATION=(PATH | URL)

### Heroku

Set up unicorn as production server, add some labs features and install the following addons: pgbackups, newrelic, sendgrid, logentries, flydata, memcachier.

    rake rails:template LOCATION=<path>/heroku.rb

### Metrics

Set up this gems for code metrics: simplecov, metric_fu, rubocop, brakeman.

    rake rails:template LOCATION=<path>/metrics.rb
