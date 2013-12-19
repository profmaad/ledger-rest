# -*- coding: utf-8 -*-
require 'spec_helper'

describe '/transactions' do
  describe 'GET',
  focus: true do
    let(:valid_json) do
      [
       {
         'cleared'  =>  true,
         'date'  =>  '2013-01-01',
         'payee'  =>  'Opening Balance',
         'pending'  =>  false,
         'posts'  =>
         [
          {
            'account'  =>  'Assets:Giro',
            'amount'  =>  2000.0,
            'commodity'  =>  'EUR'
          },
          {
            'account'  =>  'Assets:Reimbursements:Hans Maulwurf',
            'amount'  =>  19.0,
            'commodity'  =>  'EUR'
          },
          {
            'account'  =>  'Equity:Opening Balances',
            'amount'  =>  -2019.0,
            'commodity'  =>  'EUR'
          }
         ]

       }, {

         'cleared'  =>  false,
         'date'  =>  '2013-12-03',
         'payee'  =>  'NaveenaPath',
         'pending'  =>  false,
         'posts'  =>
         [
          {
            'account'  =>  'Expenses:Restaurants',
            'amount'  =>  9.0,
            'commodity'  =>  'EUR'
          },
          {
            'account'  =>  'Assets:Cash',
            'amount'  =>  -9.0,
            'commodity'  =>  'EUR'
          }
         ]

       }, {

         'cleared'  =>  false,
         'date'  =>  '2013-12-05',
         'payee'  =>  'Shikgoo',
         'pending'  =>  false,
         'posts'  =>
         [
          {
            'account'  =>  'Expenses:Restaurants',
            'amount'  =>  12.0,
            'commodity'  =>  'EUR'
          },
          {
            'account'  =>  'Liabilities:Max Mustermann',
            'amount'  =>  -12.0,
            'commodity'  =>  'EUR'
          }
         ]

       }, {

         'cleared'  =>  false,
         'date'  =>  '2013-12-10',
         'note'  =>  ' Sonnenblumenkernbrot',
         'payee'  =>  'Bioladen Tegeler Stra\u00dfe',
         'pending'  =>  false,
         'posts'  =>
         [
          {
            'account'  =>  'Assets:Reimbursements:Hans Maulwurf',
            'amount'  =>  3.1,
            'commodity'  =>  'EUR'
          },
          {
            'account'  =>  'Assets:Cash',
            'amount'  =>  -3.1,
            'commodity'  =>  'EUR'
          }
         ]

       }, {

         'aux_date'  =>  '2013-12-02',
         'cleared'  =>  true,
         'date'  =>  '2013-12-01',
         'payee'  =>  'Sparkasse',
         'pending'  =>  false,
         'posts'  =>
         [
          {
            'account'  =>  'Assets:Cash',
            'amount'  =>  50.0,
            'commodity'  =>  'EUR'
          },
          {
            'account'  =>  'Assets:Giro',
            'amount'  =>  -50.0,
            'commodity'  =>  'EUR'
          }
         ]

       }, {

         'cleared'  =>  false,
         'date'  =>  '2013-12-04',
         'payee'  =>  'Trattoria La Vialla',
         'pending'  =>  false,
         'posts'  =>
         [
          {
            'account'  =>  'Expenses:Restaurants',
            'amount'  =>  32.2,
            'commodity'  =>  'EUR'
          },
          {
            'account'  =>  'Assets:Cash',
            'amount'  =>  -32.2,
            'commodity'  =>  'EUR'
          }
         ]

       }, {

         'cleared'  =>  false,
         'date'  =>  '2013-12-06',
         'payee'  =>  'Customer X',
         'pending'  =>  false,
         'posts'  =>
         [
          {
            'account'  =>  'Assets:Giro',
            'amount'  =>  1200.0,
            'commodity'  =>  'EUR'
          },
          {
            'account'  =>  'Income:Invoice',
            'amount'  =>  -1200.0,
            'commodity'  =>  'EUR'
          }
         ]
       }
      ]

      [
       {
         'date' => '2013-01-01',
         'payee' => 'Opening Balance',
         'cleared' => true,
         'posts' =>
         [
          {
            'account' => 'Assets:Giro',
            'amount' => 2000.0,
            'commodity' => 'EUR'
          }, {
            'account' => 'Assets:Reimbursements:Hans Maulwurf',
            'amount' => 19.0,
            'commodity' => 'EUR'
          }, {
            'account' => 'Equity:Opening Balances',
            'amount' => -2019.0,
            'commodity' => 'EUR'
          }
         ],
         'pending' => false
       }, {
         'date' => '2013-12-03',
         'payee' => 'NaveenaPath',
         'cleared' => false,
         'posts' =>
         [
          {
            'account' => 'Expenses:Restaurants',
            'amount' => 9.0,
            'commodity' => 'EUR'
          }, {
            'account' => 'Assets:Cash',
            'amount' => -9.0,
            'commodity' => 'EUR'
          }
         ],
         'pending' => false
       }, {
         'date' => '2013-12-05',
         'payee' => 'Shikgoo',
         'cleared' => false,
         'posts' =>
         [
          {
            'account' => 'Expenses:Restaurants',
            'amount' => 12.0,
            'commodity' => 'EUR'
          }, {
            'account' => 'Liabilities:Max Mustermann',
            'amount' => -12.0,
            'commodity' => 'EUR'
          }
         ],
         'pending' => false
       }, {
         'posts' =>
         [
          {
            'account' => 'Assets:Reimbursements:Hans Maulwurf',
            'amount' => 3.1,
            'commodity' => 'EUR'
          }, {
            'account' => 'Assets:Cash',
            'amount' => -3.1,
            'commodity' => 'EUR'
          }
         ],
         'note' => 'Sonnenblumenkernbrot',
         'payee' => 'Bioladen Tegeler Straße',
         'date' => '2013-12-10',
         'cleared' => false,
         'pending' => false
       }, {
         'aux_date' => '2013-12-02',
         'posts' =>
         [
          {
            'account' => 'Assets:Cash',
            'amount' => 50.0,
            'commodity' => 'EUR'
          }, {
            'account' => 'Assets:Giro',
            'amount' => -50.0,
            'commodity' => 'EUR'
          }
         ],
         'payee' => 'Sparkasse',
         'date' => '2013-12-01',
         'cleared' => true,
         'pending' => false
       }, {
         'date' => '2013-12-04',
         'payee' => 'Trattoria La Vialla',
         'cleared' => false,
         'posts' =>
         [
          {
            'account' => 'Expenses:Restaurants',
            'amount' => 32.2,
            'commodity' => 'EUR'
          }, {
            'account' => 'Assets:Cash',
            'amount' => -32.2,
            'commodity' => 'EUR'
          }
         ],
         'pending' => false
       }, {
         'date' => '2013-12-06',
         'payee' => 'Customer X',
         'cleared' => false,
         'posts' =>
         [
          {
            'account' => 'Assets:Giro',
            'amount' => 1200.0,
            'commodity' => 'EUR'
          }, {
            'account' => 'Income:Invoice',
            'amount' => -1200.0,
            'commodity' => 'EUR'
          }
         ],
         'pending' => false
       }
      ]
    end

    it 'returns all transactions' do
      get '/transactions'
      JSON.parse(last_response.body).should deep_eq valid_json
    end
  end

  describe 'POST' do
    it 'adds a new transaction to the append file'
  end

  describe 'PUT' do
    it 'updates a transaction'
  end
end
