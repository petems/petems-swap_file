source "http://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.4.0'
  gem "puppet-lint"
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "beaker", :git => 'https://github.com/puppetlabs/beaker.git'
  gem "beaker-rspec", :git => 'https://github.com/puppetlabs/beaker-rspec.git'
  gem "vagrant-wrapper"
  gem "puppet-blacksmith"
  gem "guard-rake"
end
