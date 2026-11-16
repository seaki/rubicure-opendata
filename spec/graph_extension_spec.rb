require File.expand_path '../spec_helper.rb', __FILE__

describe "graphs requested with a file extension" do
  {
    'ttl' => 'text/turtle',
    'nt' => 'application/n-triples',
    'jsonld' => 'application/ld+json',
    'rdf' => 'application/rdf+xml',
  }.each do |ext, content_type|
    it "serves /precure.#{ext} as #{content_type}" do
      get "/precure.#{ext}"
      expect(last_response).to be_ok
      expect(last_response.content_type).to start_with(content_type)

      graph = RDF::Graph.new << RDF::Reader.for(file_extension: ext.to_sym).new(last_response.body)
      expect(graph.subjects.count).to eq Precure.all_girls.count
    end
  end

  %w[series movies].each do |name|
    it "serves /#{name}.ttl" do
      get "/#{name}.ttl"
      expect(last_response).to be_ok
      expect(last_response.content_type).to start_with('text/turtle')
      expect(RDF::Graph.new << RDF::Turtle::Reader.new(last_response.body)).not_to be_empty
    end
  end

  it "returns 404 for an unknown extension" do
    get '/precure.xyz'
    expect(last_response.status).to eq 404
  end
end
