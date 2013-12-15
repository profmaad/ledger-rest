# -*- coding: utf-8 -*-
require 'spec_helper'

describe '/register' do
  context 'normal' do
    let(:valid_response) do
      [
       {
         'date' => '2013-12-01',
         'effective_date' => nil,
         'code' => nil,
         'cleared' => false,
         'pending' => false,
         'payee' => 'Sparkasse',
         'postings' =>
         [
          { 'account' => 'Assets:Cash',
            'amount' => '50',
            'total' => '50',
            'commodity' => 'EUR'
          },
          {
            'account' => 'Assets:Giro',
            'amount' => '-50',
            'total' => '-50',
            'commodity' => 'EUR'
          }
         ]
       }
      ]
    end

    it 'shows all fields' do
      get '/register', query: '-p "2013-12-01"'
      JSON.parse(last_response.body).should deep_eq valid_response
    end
  end

  context 'daily report' do
    let(:valid_response) do
      [
       {
         'beginning' => '2013-12-03',
         'end'       => '2013-12-03',
         'postings'  =>
         [
          {
            'account'   => 'Expenses:Restaurants',
            'amount'    => '9',
            'total'     => '9',
            'commodity' => 'EUR'
          }
         ]
       }, {
         'beginning' => '2013-12-04',
         'end'       => '2013-12-04',
         'postings'  =>
         [
          {
            'account'   => 'Expenses:Restaurants',
            'amount'    => '32.2',
            'total'     => '32.2',
            'commodity' => 'EUR'
          }
         ]
       }, {
         'beginning' => '2013-12-05',
         'end'       => '2013-12-05',
         'postings'  =>
         [
          {
            'account'   => 'Expenses:Restaurants',
            'amount'    => '12',
            'total'     => '12',
            'commodity' => 'EUR'
          }
         ]
       }
      ]
    end

    it 'shows beginning, end and postings with account, amount and total' do
      get '/register', query: '--daily ^Expenses'
      JSON.parse(last_response.body).should deep_eq valid_response
    end
  end

  context 'weekly report' do
    let(:valid_response) do
      [
       {
         'beginning' => '2013-12-01',
         'end'       => '2013-12-07',
         'postings'  =>
         [
          {
            'account'   => 'Expenses:Restaurants',
            'amount'    => '53.2',
            'total'     => '53.2',
            'commodity' => 'EUR'
          }
         ]
       }
      ]
    end

    it 'shows beginning, end and postings with account, amount and total' do
      get '/register', query: '-W ^Expenses'
      JSON.parse(last_response.body).should deep_eq valid_response
    end
  end

  context 'monthly report' do
    let(:valid_response) do
      [
       {
         'beginning' => '2013-12-01',
         'end'       => '2013-12-31',
         'postings'  =>
         [
          {
            'account'   => 'Expenses:Restaurants',
            'amount'    => '53.2',
            'total'     => '53.2',
            'commodity' => 'EUR'
          }
         ]
       }
      ]
    end

    it 'shows beginning, end and postings with account, amount and total' do
      get '/register', query: '-M ^Expenses'
      JSON.parse(last_response.body).should deep_eq valid_response
    end
  end

  context 'quarterly report' do
    let(:valid_response) do
      [
       {
         'beginning' => '2013-10-01',
         'end'       => '2013-12-31',
         'postings'  =>
         [
          {
            'account'   => 'Expenses:Restaurants',
            'amount'    => '53.2',
            'total'     => '53.2',
            'commodity' => 'EUR'
          }
         ]
       }
      ]
    end

    it 'shows beginning, end and postings with account, amount and total' do
      get '/register', query: '--quarterly ^Expenses'
      JSON.parse(last_response.body).should deep_eq valid_response
    end
  end

  context 'yearly report' do
    let(:valid_response) do
      [
       {
         'beginning' => '2013-01-01',
         'end'       => '2013-12-31',
         'postings'  =>
         [
          {
            'account'   => 'Expenses:Restaurants',
            'amount'    => '53.2',
            'total'     => '53.2',
            'commodity' => 'EUR'
          }
         ]
       }
      ]
    end

    it 'shows beginning, end and postings with account, amount and total' do
      get '/register', query: '-Y ^Expenses'
      JSON.parse(last_response.body).should deep_eq valid_response
    end
  end

  context 'report by payee' do
    let(:valid_response) do
      [
       {
         'payee'    => 'NaveenaPath',
         'postings' =>
         [
          {
            'account'   => 'Expenses:Restaurants',
            'amount'    => '9',
            'total'     => '9',
            'commodity' => 'EUR'
          }
         ]
       }, {
         'payee'    => 'Shikgoo',
         'postings' =>
         [
          {
            'account'   => 'Expenses:Restaurants',
            'amount'    => '12',
            'total'     => '12',
            'commodity' => 'EUR'
          }
         ]
       }, {
         'payee'    => 'Trattoria La Vialla',
         'postings' =>
         [
          {
            'account'   => 'Expenses:Restaurants',
            'amount'    => '32.2',
            'total'     => '32.2',
            'commodity' => 'EUR'
          }
         ]
       }
      ]
    end

    it 'shows beginning, end and postings with account, amount and total' do
      get '/register', query: '--by-payee ^Expenses'
      JSON.parse(last_response.body).should deep_eq valid_response
    end
  end
end
