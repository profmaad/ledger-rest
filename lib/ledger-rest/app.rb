# -*- coding: utf-8 -*-
require 'sinatra/base'

require 'ledger-rest/ledger'
require 'ledger-rest/ledger/balance'
require 'ledger-rest/ledger/transaction'
require 'ledger-rest/ledger/register'
require 'ledger-rest/ledger/budget'
require 'ledger-rest/ledger/entry'
require 'ledger-rest/git'
require 'ledger-rest/core_ext'

module LedgerRest
  class App < Sinatra::Base
    configure do |c|
      config = {}
      filename = ENV['CONFIG_FILE'] || 'ledger-rest.yml'
      begin
        config = YAML.load_file(filename)
        config.symbolize_keys!
      rescue Errno::ENOENT
        raise "'#{filename}' not found."
      end

      Ledger.configure(config)
      Git.configure(config)
    end

    get '/version' do
      content_type :json
      {
        'version' => LedgerRest::VERSION,
        'ledger-version' => Ledger.version
      }.to_json
    end

    get '/balance/?:query?' do
      content_type :json
      Ledger.balance(params[:query]).to_json
    end

    get '/budget/?:query?' do
      content_type :json
      Ledger::Budget.json(params[:query])
    end

    get '/register/?:query?' do
      content_type :json
      Ledger::Register.json(params[:query])
    end

    get '/accounts/?:query?' do
      content_type :json
      Ledger.accounts(params[:query]).to_json
    end

    get '/payees/?:query?' do
      content_type :json
      Ledger.payees(params[:query]).to_json
    end

    # gets a potential new entry via the entry command
    get '/transactions/entry/?:desc?' do
      content_type :json
      { transaction: Ledger::Entry.get(params[:desc]) }.to_json
    end

    # creates a new entry based on the
    post '/transactions/entry/?:desc?' do
      content_type :json
      { transaction: Ledger::Entry.append(params[:desc]) }.to_json
    end

    get '/transactions/?:query?' do
      content_type :json
      Ledger.transactions(params[:query])
    end

    post '/transactions' do
      content_type :json
      begin
        params = JSON.parse(params[:transaction], symbolize_names: true)

        transaction = Transaction.create params

        fail 'Verification error' unless transaction.valid?

        Git.invoke :before_write

        @@ledger.append transaction

        Git.invoke :after_write

        [201, { transaction: transaction }.to_json]
      rescue JSON::ParserError => e
        [422, { error: true, message: "Unprocessible Entity: '#{e}'" }.to_json ]
      rescue RuntimeError => e
        [400, { error: true, message: "Adding the transaction failed: '#{e}'" }.to_json ]
      end
    end

    put '/transactions/:meta' do
      'Not yet implemented!'
    end

    delete '/transactions/:meta' do
      'Not yet implemented!'
    end
  end
end
