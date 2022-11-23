# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

ruby '>= 2.7.5'

gem "linkeddata"
gem "rdf-turtle"
gem "rubicure"
gem "sinatra"
gem "slim"
gem "sparql"
gem "thin"

group :test do
  gem "rack-test"
  gem "rspec"
end

group :development, :test do
  gem "byebug"
  gem "shotgun"
end
