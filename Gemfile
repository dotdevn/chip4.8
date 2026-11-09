source "https://rubygems.org"

ruby file: ".ruby-version"

gem "rails", "~> 8.1.4"
gem "sprockets-rails"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "jbuilder"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "sqlite3", ">= 1.4"
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
end

group :development do
  gem "web-console"
end

group :test do
  gem "rspec-rails", "~> 7.1"
end

group :production do
  gem "pg", ">= 1.6.0"
end
