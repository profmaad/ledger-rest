require 'spec_helper'

describe '/version' do
  it 'returns the ledger-rest version' do
    get '/version'

    JSON.parse(last_response.body).should == {
      'version' => LedgerRest::VERSION,
      'ledger-version' => LedgerRest::Ledger.version
    }
  end
end
