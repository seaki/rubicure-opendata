require File.expand_path '../spec_helper.rb', __FILE__

describe "individual resources" do
  schema = RDF::Vocabulary.new("https://rubicure-rdf.sastudio.jp/rubicure-schema.ttl#")
  base = "https://rubicure-rdf.sastudio.jp/rdfs"

  def fetch_graph(path)
    get path, {}, 'HTTP_ACCEPT' => 'application/n-triples'
    expect(last_response).to be_ok
    RDF::Graph.new << RDF::NTriples::Reader.new(last_response.body)
  end

  it "serves a Precure" do
    graph = fetch_graph('/rdfs/precure/cure_sparkle')
    subject = RDF::URI("#{base}/precure/cure_sparkle")

    expect(graph).to have_statement(RDF::Statement(subject, RDF.type, schema["Precure"]))
    expect(graph.first_object(subject: subject, predicate: RDF::RDFS.label)).to eq RDF::Literal(Cure.sparkle.precure_name)
    expect(graph.first_object(subject: subject, predicate: schema["CastName"])).to eq RDF::Literal(Cure.sparkle.cast_name)
  end

  it "serves a series with links to its Precure" do
    graph = fetch_graph('/rdfs/series/maho_girls')
    subject = RDF::URI("#{base}/series/maho_girls")

    expect(graph).to have_statement(RDF::Statement(subject, RDF.type, schema["Series"]))
    expect(graph.query({subject: subject, predicate: schema["Precure"]}).map(&:object)).to match_array(
      Rubicure::Series.find(:maho_girls).girls.map { |girl| RDF::URI("#{base}/precure/#{girl.girl_name}") }
    )
  end

  it "serves a movie" do
    graph = fetch_graph('/rdfs/movies/dx1')
    subject = RDF::URI("#{base}/movies/dx1")

    expect(graph).to have_statement(RDF::Statement(subject, RDF.type, schema["Movies"]))
    expect(graph.first_object(subject: subject, predicate: RDF::RDFS.label)).to eq RDF::Literal(Rubicure::Movie.find(:dx1).title)
  end

  %w[
    /rdfs/precure/no_such_cure
    /rdfs/series/no_such_series
    /rdfs/movies/no_such_movie
    /rdfs/no_such_predicate/cure_sparkle
  ].each do |path|
    it "returns 404 for #{path}" do
      get path
      expect(last_response.status).to eq 404
    end
  end

  it "does not call methods named by the request" do
    # Cure.send('exit') used to reach Kernel#exit
    get '/rdfs/precure/exit'
    expect(last_response.status).to eq 404
  end
end
