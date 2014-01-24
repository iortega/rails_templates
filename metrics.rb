# https://github.com/rails/rails/issues/3153
def bundle_install
  Bundler.with_clean_env do
    run "bundle install"
  end
end

# Coveralls
# gem 'coveralls', require: false
# bundle_install
# 
# inject_into_file 'spec/spec_helper.rb', after: 'ENV["RAILS_ENV"] ||= \'test\'' do
# <<-CODE
# 
# require 'coveralls'
# Coveralls.wear!('rails')
# CODE
# end

# SimpleCov
gem 'simplecov', require: false, group: :test
bundle_install

inject_into_file 'spec/spec_helper.rb', after: 'ENV["RAILS_ENV"] ||= \'test\'' do
<<-CODE

require 'simplecov'
CODE
end

file '.simplecov', <<-CODE
  class LineFilter < SimpleCov::Filter
    def matches?(source_file)
      source_file.lines.count < filter_argument
    end
  end

  SimpleCov.start 'rails' do
    add_group "Long files" do |src_file|
      src_file.lines.count > 100
    end
    add_group "Short files", LineFilter.new(5)
  end
CODE

gem 'metric_fu', group: [:development, :test]
bundle_install

run "gem install rubocop"
run "gem install brakeman"
