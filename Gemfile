source 'http://rubygems.org'

group :test do
  if puppetversion = ENV['PUPPET_GEM_VERSION']
    gem 'puppet', puppetversion, :require => false
  else
    gem 'puppet', ENV['PUPPET_VERSION'] || '~> 7.12.0'
  end

  gem 'rspec'
  gem 'safe_yaml'
  gem 'rake'
  gem 'puppet-lint'
  gem 'rspec-puppet'
  gem 'puppet-syntax'
  gem 'puppetlabs_spec_helper'
  gem 'simplecov'
  gem 'simplecov-console'
  gem 'metadata-json-lint'
end

group :development do
  gem 'puppet-blacksmith'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'github_changelog_generator'
  gem 'activesupport'
end

group :system_tests do
  gem "beaker"
  gem "beaker-rspec"
  gem 'serverspec'
  gem 'specinfra'
end

