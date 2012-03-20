require 'rubygems'
require 'json'
require 'yaml'
require 'shellwords'
require 'escape'

require 'sinatra/base'

class LedgerRest < Sinatra::Base
  VERSION = "1.0"

  CONFIG_FILE = "ledger-rest.yml"

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

  get '/version' do
    { "version" => VERSION, "ledger-version" => %x[#{settings.ledger_bin} --version | head -n1 | sed 's/^Ledger \\(.*\\), .*$/\\1/'].rstrip }.to_json
  end
  
  get '/balance' do
    ledger_balance ""
  end
  get '/balance/:query' do
    ledger_balance params[:query]
  end
  post '/balance' do
    ledger_balance params[:query]
  end

  get '/budget' do
    ledger_budget ""
  end
  get '/budget/:query' do
    ledger_budget params[:query]
  end
  post '/budget' do
    ledger_budget params[:query]
  end

  get '/register' do
    ledger_register ""
  end
  get '/register/:query' do
    ledger_register params[:query]
  end
  post '/register' do
    ledger_register params[:query]
  end

  get '/accounts' do
    ledger_accounts ""
  end
  get '/accounts/:query' do
    ledger_accounts params[:query]
  end
  post '/accounts' do
    ledger_accounts params[:query]
  end
  get '/payees' do
    ledger_payees ""
  end
  get '/payees/:query' do
    ledger_payees params[:query]
  end
  post '/payees' do
    ledger_payees params[:query]
  end

  helpers do
    def ledger(parameters)
      parameters = Escape.shell_command(parameters.shellsplit)
      puts %Q[#{settings.ledger_bin} -f #{settings.ledger_file} #{parameters}]
      %x[#{settings.ledger_bin} -f #{settings.ledger_file} #{parameters}].rstrip
    end

    def jsonify_obj(s)
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

    def ledger_balance(parameters)
      parameters = "balance "+parameters
      result = %Q["accounts": { #{ledger(parameters)}]
      return jsonify_obj(result)
    end
    def ledger_budget(parameters)
      parameters = "budget "+parameters
      result = %Q["accounts": { #{ledger(parameters)}]
      return jsonify_obj(result)
    end
    def ledger_register(parameters)
      parameters = "register "+parameters
      result = %Q<"postings": [ #{ledger(parameters)}>
        return jsonify_array(result)
    end
    def ledger_accounts(parameters)
      parameters = "accounts "+parameters
      accounts = ledger(parameters).split("\n")
      return {"accounts" => accounts}.to_json
    end
    def ledger_payees(parameters)
      parameters = "payees "+parameters
      payees = ledger(parameters).split("\n")
      return {"payees" => payees}.to_json
    end
  end
end
