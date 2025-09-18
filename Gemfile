# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

ruby '>= 3.1'

gem "linkeddata"
gem "rdf-turtle"
gem "rubicure"
gem "sinatra"
gem "rackup"
gem "slim"
gem "sparql"
gem "puma"
gem "csv"
gem "activesupport", "<9.0"

group :test do
  gem "rack-test"
  gem "rspec"
end

group :development, :test do
  gem "byebug"
  gem "shotgun"
end
