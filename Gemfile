# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "linkeddata"
gem "rdf-turtle"
gem "rubicure"
gem "sinatra"
gem "rackup"
gem "slim"
gem "sparql"
gem "puma"
gem "csv"
gem "activesupport"
# json-ld 3.3.2 cannot write JSON-LD with json 3.x
gem "json", "< 3"

group :test do
  gem "rack-test"
  gem "rspec"
end

group :development, :test do
  gem "byebug"
  gem "shotgun"
end
