require File.expand_path '../spec_helper.rb', __FILE__

describe "rubicure-schema.ttl" do
  schema_prefix = "https://rubicure-rdf.sastudio.jp/rubicure-schema.ttl#"

  def fetch_graph(path)
    get path, {}, 'HTTP_ACCEPT' => 'application/n-triples'
    expect(last_response).to be_ok
    RDF::Graph.new << RDF::NTriples::Reader.new(last_response.body)
  end

  let(:defined_terms) do
    get '/rubicure-schema.ttl'
    expect(last_response).to be_ok
    (RDF::Graph.new << RDF::Turtle::Reader.new(last_response.body.force_encoding('UTF-8'))).subjects.map(&:to_s)
  end

  %w[precure series movies].each do |name|
    it "defines every term used in /#{name}" do
      graph = fetch_graph("/#{name}")
      types = graph.query({predicate: RDF.type}).map(&:object)
      used_terms = (graph.predicates + types).map(&:to_s).uniq.select { |term| term.start_with?(schema_prefix) }

      expect(used_terms).not_to be_empty
      expect(used_terms - defined_terms).to be_empty
    end
  end
end
