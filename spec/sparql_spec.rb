require File.expand_path '../spec_helper.rb', __FILE__

describe "SPARQL endpoint" do
  # the "Get Precure name from Maho Girls Precure!" example on the home page
  maho_girls_query = <<~SPARQL
    PREFIX schema: <https://rubicure-rdf.sastudio.jp/rubicure-schema.ttl#>
    PREFIX precure: <https://rubicure-rdf.sastudio.jp/rdfs/precure/>
    PREFIX series: <https://rubicure-rdf.sastudio.jp/rdfs/series/>
    SELECT ?precure_name
    WHERE {
      series:maho_girls schema:Precure ?precure.
      ?precure schema:PrecureName ?precure_name.
    }
  SPARQL

  def precure_names
    expect(last_response).to be_ok
    JSON.parse(last_response.body)['results']['bindings'].map { |b| b['precure_name']['value'] }
  end

  let(:maho_girls_names) { Rubicure::Series.find(:maho_girls).girls.map(&:precure_name) }

  it "answers the home page example via GET" do
    get '/sparql', {query: maho_girls_query}, 'HTTP_ACCEPT' => 'application/sparql-results+json'
    expect(precure_names).to match_array(maho_girls_names)
  end

  it "answers the home page example via POST" do
    post '/sparql', {query: maho_girls_query}, 'HTTP_ACCEPT' => 'application/sparql-results+json'
    expect(precure_names).to match_array(maho_girls_names)
  end

  it "returns 400 for a malformed query" do
    get '/sparql', query: 'SELECT WHERE {'
    expect(last_response.status).to eq 400
    expect(last_response.body).to include 'syntax error'
  end

  it "does not fetch a query from a URL" do
    # a URL is not a SPARQL query; it must be rejected without any request being made to it
    expect(RDF::Util::File).not_to receive(:open_file)
    get '/sparql', query: 'http://127.0.0.1:9/query.rq'
    expect(last_response.status).to eq 400
  end
end
