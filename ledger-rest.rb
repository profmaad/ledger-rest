require 'rubygems'
require 'json'
require 'escape'

require 'sinatra'

if development?
  require 'sinatra/reloader'

  settings.bind = "127.0.0.1"
end

VERSION = "0.0"
LEDGER_BIN = "/usr/bin/ledger"
LEDGER_FILE = ENV['LEDGER_FILE']
ENV['HOME'] = ''

get '/version' do
  { "version" => VERSION, "ledger-version" => %x[#{LEDGER_BIN} --version | head -n1 | sed 's/^Ledger \\(.*\\), .*$/\\1/'].rstrip }.to_json
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
  ledger_accounts
end

helpers do
  def ledger(parameters)
    parameters = Escape.shell_command(parameters.split(' '))
    puts %Q[#{LEDGER_BIN} -f #{LEDGER_FILE} #{parameters}]
    %x[#{LEDGER_BIN} -f #{LEDGER_FILE} #{parameters}].rstrip
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
  def ledger_accounts
    accounts = ledger("accounts").split("\n")
    return {"accounts" => accounts}.to_json
  end
end
