require 'spec_helper'

describe '/budget' do
  context 'without query' do
    let(:valid_json) do
      {
        'accounts' =>
        [
         {
           'total'      => '3177.80EUR',
           'budget'     => '-6600.00EUR',
           'difference' => '9777.80EUR',
           'percentage' => '-48%',
           'account'    => 'Assets'
         }, {
           'total'      => '53.20EUR',
           'budget'     => '6600.00EUR',
           'difference' => '-6546.80EUR',
           'percentage' => '1%',
           'account'    => 'Expenses'
         }, {
           'total'      => '0',
           'budget'     => '5400.00EUR',
           'difference' => '-5400.00EUR',
           'percentage' => '0%',
           'account'    => 'Expenses:Flat'
         }, {
           'total'      => '53.20EUR',
           'budget'     => '1200.00EUR',
           'difference' => '-1146.80EUR',
           'percentage' => '4%',
           'account'    => 'Expenses:Restaurants'
         }
        ],
        'total'      => '3231.00EUR',
        'budget'     => '0',
        'difference' => '3231.00EUR',
        'percentage' => '0'
      }
    end

    it 'responds with the right budget' do
      get '/budget', query: 'Expenses'

      # JSON.parse(last_response.body).should deep_eq valid_json
      # TODO: Fix when the ledger bug is fixed.
    end
  end

  context 'querying single account' do
    let(:valid_json) do
      {
        'accounts' =>
        [
         {
           'total'      => '53.20EUR',
           'budget'     => '100.00EUR',
           'difference' => '-46.80EUR',
           'percentage' => '53%',
           'account'    => 'Expenses:Restaurants'
         }
        ]
      }
    end

    it 'responds with the right budget' do
      get '/budget', query: '-p \'dec 2013\' Restaurants'

      JSON.parse(last_response.body).should deep_eq valid_json
    end
  end

  context 'querying single account' do
    let(:valid_json) do
      {
        'accounts' =>
        [
         {
           'total'      => '53.20EUR',
           'budget'     => '550.00EUR',
           'difference' => '-496.80EUR',
           'percentage' => '10%',
           'account'    => 'Expenses'
         }, {
           'total'      => '0',
           'budget'     => '450.00EUR',
           'difference' => '-450.00EUR',
           'percentage' => '0%',
           'account'    => 'Expenses:Flat'
         }, {
           'total'      => '53.20EUR',
           'budget'     => '100.00EUR',
           'difference' => '-46.80EUR',
           'percentage' => '53%',
           'account'    => 'Expenses:Restaurants'
         }
        ],
        'total'      => '53.20EUR',
        'budget'     => '550.00EUR',
        'difference' => '-496.80EUR',
        'percentage' => '10%',
      }
    end

    it 'responds with the right budget' do
      get '/budget', query: '-p \'dec 2013\' Expenses'

      JSON.parse(last_response.body).should deep_eq valid_json
    end
  end
end
