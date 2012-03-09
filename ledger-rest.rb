require 'rubygems'
require 'json'

require 'sinatra'
require 'sinatra/reloader' if development?

VERSION = "0.0"
LEDGER_BIN = "/home/profmaad/compilation/ledger/ledger"
LEDGER_FILE = ENV['LEDGER_FILE']

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

helpers do
  def ledger(parameters)
    puts %Q[#{LEDGER_BIN} -f #{LEDGER_FILE} #{parameters}]
    %x[#{LEDGER_BIN} -f #{LEDGER_FILE} #{parameters}].rstrip
  end

  def jsonify(s)
    result = "{"
    result += s
    result += "}" if result.end_with?(",")
    result += "}"
    result.gsub!(",}", "}")

    return result
  end

  def ledger_balance(parameters)
    parameters = "bal "+parameters
    result = %Q["accounts": { #{ledger(parameters)}]
    return jsonify(result)
  end
  def ledger_budget(parameters)
    parameters = "budget "+parameters
    result = %Q["accounts": { #{ledger(parameters)}]
    return jsonify(result)
  end
end
