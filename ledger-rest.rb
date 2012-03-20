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
  end
end
