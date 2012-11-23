# -*- coding: utf-8 -*-
require 'ledger-rest/ledger/parser'

module LedgerRest
  class Ledger
    class << self

      attr_accessor :rcfile, :bin, :file, :append_file, :home

      def configure(options)
        @bin = options[:ledger_bin] || "/usr/bin/ledger"
        @file = options[:ledger_file] || ENV['LEDGER_FILE']
        @append_file = options[:ledger_append_file] || ENV['LEDGER_FILE']
        @home = options[:ledger_home] || ''      # Return a budget representation
      end

      # Execute ledger command with given parameters
      def exec(cmd, params = {})
        Git.invoke :before_read

        params = {
          '-f' => @file
        }.merge(params)

        params = params.inject '' do |acc, key, val|
          acc << " #{key} #{Escape.shell_single_word(val)}"
        end

        command = "#{bin} #{params} #{cmd}"

        puts command
        `#{command}`.rstrip
      end

      # Append a new transaction to the append_file.
      def append transaction
        File.open(append_file, "a+") do |f|
          if f.pos == 0
            last_char = "\n"
          else
            f.pos = f.pos-1
            last_char = f.getc
          end

          f.write "\n" unless last_char == "\n"
          f.write(transaction_string)
        end
      end

      # Return the ledger version.
      def version
        exec("--version").match(/^Ledger (.*),/)[1]
      end

      # Get a new transaction entry based on previous entries found
      # in the append file.
      def entry description
        result = exec "entry #{description}", '-f' => append_file


      end

      # Return a list of payees.
      def payees(query = nil)
        result = exec "payees #{query if query}"
        { :payees => result.split("\n") }
      end

      # Returns an Array of payees with their respective usage count.
      def payees_with_usage

      end

      # Return an array of accounts.
      def accounts(query = nil)
        result = exec "accounts #{query if query}"
        { :accounts => result.split("\n") }
      end

      # Return an Array of accounts with their respective usage count.
      def accounts_with_usage

      end
    end

  end
end