# -*- coding: utf-8 -*-
require 'spec_helper'

describe '/transactions' do
  describe 'GET' do
    let(:valid_json) do
      [
       {
         'date' => '2013/01/01',
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
         'date' => '2013/12/03',
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
         'date' => '2013/12/05',
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
         'date' => '2013/12/10',
         'cleared' => false,
         'pending' => false
       }, {
         'effective_date' => '2013/12/02',
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
         'date' => '2013/12/01',
         'cleared' => true,
         'pending' => false
       }, {
         'date' => '2013/12/04',
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
         'date' => '2013/12/06',
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
    let(:transaction) do
      {
        date: '2013/12/12',
        cleared: true,
        payee: 'New Payee',
        postings:
        [
         {
           account: 'Expenses:Restaurants',
           amount: 11.0,
           commodity: 'EUR'
         },
         {
           account: 'Assets:Cash',
           amount: -11.0,
           commodity: 'EUR'
         }
        ]
      }
    end

    let(:correct_response) do
      { transaction: transaction }
    end

    it 'adds a new transaction to the append file' do
      restore_file('spec/files/append.ledger') do
        post '/transactions', transaction.to_json

        last_response.status.should == 201
        JSON.parse(last_response.body, symbolize_names: true).should deep_eq correct_response
        puts File.read('spec/files/append.ledger').should == <<RESULT
2013/12/03 NaveenaPath
    Expenses:Restaurants                     9.00EUR
    Assets:Cash

2013/12/05 Shikgoo
    Expenses:Restaurants                    12.00EUR
    Liabilities:Max Mustermann
    ; meta_info: Some interesting meta information

2013/12/10 Bioladen Tegeler Straße
    ; Sonnenblumenkernbrot
    Assets:Reimbursements:Hans Maulwurf      3.10EUR
    Assets:Cash

2013/12/12 * New Payee
    Expenses:Restaurants  11.00EUR
    Assets:Cash  -11.00EUR
RESULT
      end
    end
  end

  describe 'PUT' do
    it 'updates a transaction'
  end
end
