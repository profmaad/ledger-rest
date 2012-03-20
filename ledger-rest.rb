# -*- coding: utf-8 -*-
require 'rubygems'
require 'json'
require 'yaml'
require 'shellwords'
require 'escape'

require 'sinatra/base'

class LedgerRest < Sinatra::Base
  VERSION = "1.0"

  CONFIG_FILE = "ledger-rest.yml"

  DATE_REGEXP = /^\d{4}\/\d{1,2}\/\d{1,2}$/

  set :ledger_bin, "/usr/bin/ledger"
  set :ledger_file, ENV['LEDGER_FILE']
  set :ledger_home, ''
  
  configure do |c|
    config = {}
    begin
      config = YAML.load_file(CONFIG_FILE)
    rescue
      puts "Failed to load config file" if config.nil?
    end

    config.each do |key,value|
      set key.to_sym, value
    end

    ENV['HOME'] = settings.ledger_home
  end

  before do
    params[:query] = "" if params[:query].nil?
  end

  get '/version' do
    { "version" => VERSION, "ledger-version" => %x[#{settings.ledger_bin} --version | head -n1 | sed 's/^Ledger \\(.*\\), .*$/\\1/'].rstrip }.to_json
  end
  
  get '/balance/?:query?' do
    ledger_json("balance", "accounts", params[:query], :object)
  end
  get '/budget/?:query?' do
    ledger_json("budget", "accounts", params[:query], :object)
  end
  get '/register/?:query?' do
    ledger_json("register", "postings", params[:query], :array)
  end

  get '/accounts/?:query?' do
    ledger_json("accounts", "accounts", params[:query], :list)
  end
  get '/payees/?:query?' do
    ledger_json("payees", "payees", params[:query], :list)
  end

  TEST_TRANSACTION = {
    :date => "2012/03/01",
    :effective_date => "2012/03/23",
    :cleared => true,
    :pending => false,
    :code => "INV#23",
    :payee => "me, myself and I",
    :postings => [
                  {:account => "Expenses:Imaginary", :amount => "€ 23", :per_unit_cost => "USD 2300", :actual_date => "2012/03/24", :effective_date => "2012/03/25"},
                  {:account => "Expenses:Magical", :amount => "€ 42", :posting_cost => "USD 23000000"},
                  "This is a freeform comment"
                 ]
  }

  post '/transactions' do
    begin
      transaction = JSON.parse(params[:transaction], :symbolize_names => true)
      return [400, "Transaction failed verification\n"] unless verify_transaction(transaction)

      puts "adding transaction: #{transaction}"
    rescue JSON::ParserError => e
      [400, "Invalid transaction: '#{e.to_s}'\n"]
    end
  end

  helpers do
    def ledger(parameters)
      parameters = Escape.shell_command(parameters.shellsplit)
      puts %Q[#{settings.ledger_bin} -f #{settings.ledger_file} #{parameters}]
      %x[#{settings.ledger_bin} -f #{settings.ledger_file} #{parameters}].rstrip
    end

    def jsonify_object(s)
      result = "{"
      result += s
      result += "}" if (result.end_with?(",") or result.end_with?(" "))
      result += "}"
      result.gsub!(",}", "}")

      return result
    end
    def jsonify_array(s)
      result = "{"
      result += s
      result += "]" if (result.end_with?(",") or result.end_with?(" "))
      result += "}"
      result.gsub!(",]", "]")

      return result
    end

    def ledger_json(command, key, parameters, type=:object)
      parameters = command + " " + parameters
      result = case type
               when :object
                 %Q["#{key}": { #{ledger(parameters)}]
               when :array
                 %Q<"#{key}": [ #{ledger(parameters)}>
               when :list
                 ledger(parameters).split("\n")
               end

      return case type
             when :object
               jsonify_object(result)
             when :array
               jsonify_array(result)
             when :list
               {key => result}.to_json
             end
    end
    
    def verify_transaction(transaction)
      unless(
             transaction[:date] =~ DATE_REGEXP and
             (transaction[:effective_date].nil? or transaction[:effective_date] =~ DATE_REGEXP) and
             (transaction[:code].nil? or !(transaction[:code] =~ /[()\n]/)) and
             !(transaction[:payee] =~ /\n/) and
             !(transaction[:postings].nil? or transaction[:postings].empty?)
             )
        return false
      end

      posting_without_amount = false
      transaction[:postings].each do |posting|
        if(
           posting[:account].nil? or
           posting[:account].empty? or
           posting[:account] =~ /  / or
           posting[:account] =~ /\n/ or
           (!posting[:amount].nil? and posting[:amount] =~ /\n/) or
           (!posting[:per_unit_cost].nil? and posting[:per_unit_cost] =~ /\n/) or
           (!posting[:posting_cost].nil? and posting[:posting_cost] =~ /\n/) or
           (!posting[:actual_date].nil? and posting[:actual_date] =~ DATE_REGEXP) or
           (!posting[:effective_date].nil? and posting[:effective_date] =~ DATE_REGEXP)
           )
          return false
        end

        if(posting[:account].nil? and posting_without_amount)
          return false
        elsif(posting[:account].nil?)
          posting_without_amount = true
        end
      end

      return true
    end
  end
end
