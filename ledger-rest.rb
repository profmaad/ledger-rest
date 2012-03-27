# -*- coding: utf-8 -*-
require 'rubygems'
require 'fileutils'
require 'json'
require 'yaml'
require 'shellwords'
require 'escape'
require 'git'

require 'sinatra/base'

class LedgerRest < Sinatra::Base
  VERSION = "1.0"

  CONFIG_FILE = "ledger-rest.yml"

  DATE_REGEXP = /^\d{4}\/\d{1,2}\/\d{1,2}$/

  set :ledger_bin, "/usr/bin/ledger"
  set :ledger_file, ENV['LEDGER_FILE']
  set :ledger_append_file, ENV['LEDGER_FILE']
  set :ledger_home, ''
  set :git_repository, File.dirname(settings.ledger_file)
  set :git_pull_before_read, false
  set :git_pull_before_write, false
  set :git_push_after_write, false
  set :git_remote, 'origin'
  set :git_branch, 'master'
  set :git_read_pull_block_time, 10*60
  
  configure do |c|
    config = {}
    begin
      config = YAML.load_file(CONFIG_FILE)
    rescue
      puts "Failed to load config file"
    end

    git_repository_set_in_config = false
    config.each do |key,value|
      set key.to_sym, value
      get_repository_set_in_config = true if(key.to_sym == :git_repository)
    end

    ENV['HOME'] = settings.ledger_home
    set :git_repository, File.dirname(settings.ledger_file) unless git_repository_set_in_config

    if(settings.git_push_after_write || settings.git_push_after_write)
      begin
        @@git_repo = Git.open(settings.git_repository)
        FileUtils.touch(settings.ledger_append_file)
        @@git_repo.add(settings.ledger_append_file)
        @@last_read_pull = Time.new-settings.git_read_pull_block_time
      rescue Exception => e
        puts "Failed to open git repo at '#{settings.git_repository}': #{e.to_s }"
        settings.git_pull_before_write = false
        settings.git_push_after_write  = false
      end
    end
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
                  {:account => "Expenses:Magical", :amount => "€ 42", :posting_cost => "USD 23000000", :virtual => true},
                  {:account => "Assets:Mighty"},
                  {:comment => "This is a freeform comment"},
                 ]
  }

  post '/transactions' do
    begin
      transaction = JSON.parse(params[:transaction], :symbolize_names => true)

      transaction_string = transaction_to_ledger(transaction)
      raise "Verification error" unless verify_transaction(transaction_string)

      @@git_repo.pull(settings.git_remote, settings.git_branch) if settings.git_pull_before_write
      File.open(settings.ledger_append_file, "a+") do |f|
        if f.pos == 0
          last_char = "\n"
        else
          f.pos = f.pos-1
          last_char = f.getc
        end

        f.write "\n" unless last_char == "\n"
        f.write(transaction_string)
      end
      if(settings.git_push_after_write)
        @@git_repo.commit_all("transaction added via ledger-rest")
        @@git_repo.push(settings.git_remote, settings.git_branch)
      end

      [200, "Transaction added successfully\n"]
    rescue JSON::ParserError => e
      [400, "Invalid transaction: '#{e.to_s}'\n"]
    rescue RuntimeError => e
      [400, "Adding the transaction failed: '#{e.to_s}'\n"]
    end
  end

  helpers do
    def ledger(parameters)
      if(settings.git_pull_before_read && (Time.new-@@last_read_pull) > settings.git_read_pull_block_time)
        begin
          @@git_repo.pull(settings.git_remote, settings.git_branch)
          @@last_read_pull = Time.new
        rescue Exception => e
          puts "Git pull failed: "+e.to_s
        end
      end
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
    
    def verify_transaction(transaction_string)
      result = IO.popen("#{settings.ledger_bin} -f - stats 2>&1", "r+") do |f|
        f.write transaction_string
        f.close_write
        f.readlines
      end

      return ($?.success? and not result.empty?)
    end

    def transaction_to_ledger(transaction)
      if(
         transaction[:date].nil? or
         transaction[:payee].nil? or
         transaction[:postings].nil?
         )
        return nil
      end

      result = ""
      
      result += transaction[:date]
      result += "="+transaction[:effective_date] unless transaction[:effective_date].nil?
      
      if transaction[:cleared]
        result += " *"
      elsif transaction[:pending]
        result += " !"
      end

      result += " ("+transaction[:code]+")" unless transaction[:code].nil?
      result += " "+transaction[:payee]
      result += "\n"

      transaction[:postings].each do |posting|
        if(posting[:comment])
          result += "  ; "+posting[:comment]+"\n"
          next
        end

        next if posting[:account].nil?

        result += "  "
        result += posting[:account]
        
        if posting[:amount].nil?
          result += "\n"
          next
        end

        result += "  "+posting[:amount]

        if(posting[:per_unit_cost])
          result += " @ "+posting[:per_unit_cost]
        elsif(posting[:posting_cost])
          result += " @@ "+posting[:posting_cost]
        end

        unless(posting[:actual_date].nil? and posting[:effective_date].nil?)
          result += "  ; ["
          result += posting[:actual_date] unless posting[:actual_date].nil?
          result += "="+posting[:effective_date] unless posting[:effective_date].nil?
          result += "]"
        end

        result += "\n"
      end

      result += "\n"
      
      return result
    end
  end
end
