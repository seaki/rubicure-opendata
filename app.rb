require 'sinatra'

require File.expand_path 'lib/rack/handle_html_charset.rb', File.dirname(__FILE__)
use Rack::HandleHtmlCharset

require 'linkeddata'
require 'rubicure'
require 'sinatra/sparql'
require 'slim'

configure do
  mime_type :ttl, 'text/turtle'
end

get '/' do
  slim :index
end

get '/precure:ext?' do
  get_graph("precure", params['ext'])
end

get '/series:ext?' do
  get_graph("series", params['ext'])
end

get '/movies:ext?' do
  get_graph("movies", params['ext'])
end

def get_graph(graph_name, ext)
  schema = RDF::Vocabulary.new("https://rubicure-rdf.sastudio.jp/rubicure-schema.ttl#")
  prefix = RDF::Vocabulary.new("https://rubicure-rdf.sastudio.jp/rdfs/#{graph_name}/")

  ext = ext.gsub('.', '') unless ext.nil?
  # follow content negotiation if no extension specified
  return self.send(graph_name) if ext.nil?

  RDF::Writer.for(ext.to_sym).buffer(
  {standard_prefixes: true, prefixes: {rubicure: schema.to_uri}}
  ) do |w|
    w << self.send(graph_name)
  end
end

get '/rdfs/:predicate/:subject' do
  graph = RDF::Graph.new

  case params['predicate']
  when 'precure' then
    get_girl(graph, Cure.send(params['subject']))
  when 'series' then
    get_series(graph, params['subject'].to_sym)
  when 'movies' then
    get_movie(graph, params['subject'].to_sym)
  end

  graph
end

get '/sparql' do
  endpoint
end

post '/sparql' do
  endpoint
end

def endpoint
  settings.sparql_options.replace(standard_prefixes: true)
  repository = RDF::Repository.new do |graph|
    graph << precure
    graph << series
    graph << movies
  end
  if params["query"]
    query = params["query"].to_s.match(/^http:/) ? RDF::Util::File.open_file(params["query"]) : ::URI.decode_www_form_component(params["query"].to_s)
    SPARQL.execute(query, repository)
  else
    settings.sparql_options.merge!(prefixes: {
      ssd: "http://www.w3.org/ns/sparql-service-description#",
      void: "http://rdfs.org/ns/void#"
    })
    service_description(repo: repository)
  end
end

def precure
  graph = RDF::Graph.new

  Precure.all_girls.each do |girl|
    get_girl(graph, girl)
  end

  graph
end

def get_girl(graph, girl)
  schema = RDF::Vocabulary.new("https://rubicure-rdf.sastudio.jp/rubicure-schema.ttl#")
  prefix = RDF::Vocabulary.new("https://rubicure-rdf.sastudio.jp/rdfs/precure/")

  s = prefix[girl.girl_name]
  p = RDF.type
  o = schema["Precure"]

  graph << RDF::Statement.new(s, p, o)

  s = prefix[girl.girl_name]
  p = RDF::RDFS.label
  o = girl.precure_name

  graph << RDF::Statement.new(s, p, o)

  %w[human_name precure_name cast_name color created_date birthday].each do |m|
    next unless girl.respond_to?(m) && girl.send(m)
    s = prefix[girl.girl_name]
    p = schema[m.camelize]
    o = girl.send(m)

    graph << RDF::Statement.new(s, p, o)
  end
end

def series
  graph = RDF::Graph.new

  Rubicure::Series.uniq_names.each do |name|
    get_series(graph, name)
  end

  graph
end

def get_series(graph, name)
  schema = RDF::Vocabulary.new("https://rubicure-rdf.sastudio.jp/rubicure-schema.ttl#")
  prefix = RDF::Vocabulary.new("https://rubicure-rdf.sastudio.jp/rdfs/series/")
  prefix_precure = RDF::Vocabulary.new("https://rubicure-rdf.sastudio.jp/rdfs/precure/")

  series = Rubicure::Series.find(name)

  s = prefix[name]
  p = RDF.type
  o = schema["Series"]

  graph << RDF::Statement.new(s, p, o)

  s = prefix[name]
  p = RDF::RDFS.label
  o = series.title

  graph << RDF::Statement.new(s, p, o)

  %w[title started_date ended_date].each do |m|
    next unless series.respond_to?(m) && series.send(m)
    s = prefix[name]
    p = schema[m.camelize]
    o = series.send(m)

    graph << RDF::Statement.new(s, p, o)
  end

  series.girls.each do |girl|
    s = prefix[name]
    p = schema["Precure"]
    o = prefix_precure[girl.girl_name]

    graph << RDF::Statement.new(s, p, o)
  end
end

def movies
  graph = RDF::Graph.new

  Rubicure::Movie.uniq_names.each do |name|
    get_movie(graph, name)
  end

  graph
end

def get_movie(graph, name)
  schema = RDF::Vocabulary.new("https://rubicure-rdf.sastudio.jp/rubicure-schema.ttl#")
  prefix = RDF::Vocabulary.new("https://rubicure-rdf.sastudio.jp/rdfs/movies/")
  prefix_precure = RDF::Vocabulary.new("https://rubicure-rdf.sastudio.jp/rdfs/precure/")

  movie = Rubicure::Movie.find(name)

  s = prefix[name]
  p = RDF.type
  o = schema["Movies"]

  graph << RDF::Statement.new(s, p, o)

  s = prefix[name]
  p = RDF::RDFS.label
  o = movie.title

  graph << RDF::Statement.new(s, p, o)

  %w[title started_date ended_date].each do |m|
    next unless movie.respond_to?(m) && movie.send(m)
    s = prefix[name]
    p = schema[m.camelize]
    o = movie.send(m)

    graph << RDF::Statement.new(s, p, o)
  end

  Precure.all_stars(name).each do |girl|
    s = prefix[name]
    p = schema["Precure"]
    o = prefix_precure[girl.girl_name]

    graph << RDF::Statement.new(s, p, o)
  end
end
