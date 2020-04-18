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
  end
  if params["query"]
    query = params["query"].to_s.match(/^http:/) ? RDF::Util::File.open_file(params["query"]) : ::URI.decode(params["query"].to_s)
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
  schema = RDF::Vocabulary.new("https://rubicure-rdf.sastudio.jp/rubicure-schema.ttl#")
  prefix = RDF::Vocabulary.new("https://rubicure-rdf.sastudio.jp/rdfs/precure/")

  graph = RDF::Graph.new

  Precure.all_girls.each do |girl|
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

  graph
end

def series
  schema = RDF::Vocabulary.new("https://rubicure-rdf.sastudio.jp/rubicure-schema.ttl#")
  prefix = RDF::Vocabulary.new("https://rubicure-rdf.sastudio.jp/rdfs/series/")
  prefix_precure = RDF::Vocabulary.new("https://rubicure-rdf.sastudio.jp/rdfs/precure/")

  graph = RDF::Graph.new

  Rubicure::Series.uniq_names.each do |name|
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

  graph
end
