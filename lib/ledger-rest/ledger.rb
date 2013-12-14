# -*- coding: utf-8 -*-
require 'ledger-rest/ledger/parser'

module LedgerRest
  class Ledger
    class << self
      attr_accessor :rcfile, :bin, :file, :append_file, :home

      def configure(options)
        @bin = options[:ledger_bin] || '/usr/bin/ledger'
        @file = options[:ledger_file] || ENV['LEDGER_FILE'] || 'main.ledger'
        @append_file =
          options[:ledger_append_file] || ENV['LEDGER_FILE'] || 'append.ledger'
        @home = options[:ledger_home] || ''
      end

      # Execute ledger command with given parameters
      def exec(cmd, options = {})
        Git.invoke :before_read

        options = {
          '-f' => @file
        }.merge(options)

        params = ''
        options.each do |key, val|
          params << " #{key} #{Escape.shell_single_word(val)}"
        end

        command = "#{bin} #{params} #{cmd}"

        `#{command}`.rstrip
      end

      # Append a new transaction to the append_file.
      def append(transaction)
        File.open(append_file, 'a+') do |f|
          if f.pos == 0
            last_char = "\n"
          else
            f.pos = f.pos - 1
            last_char = f.getc
          end

          f.write "\n" unless last_char == "\n"
          f.write(transaction.to_ledger)
        end
      end

      # Return the ledger version.
      def version
        exec('--version').match(/^Ledger (.*),/)[1]
      end

      # Get a new transaction entry based on previous entries found
      # in the append file.
      def entry(description)
        result = exec "entry #{description}", '-f' => append_file
      end

      # Return a list of payees.
      def payees(query = nil)
        exec("payees #{query if query}").split("\n")
      end

      # Returns an Array of payees with their respective usage count.
      def payees_with_usage; end

      # Return an array of accounts.
      def accounts(query = nil)
        exec("accounts #{query if query}").split("\n")
      end

      # Return an Array of accounts with their respective usage count.
      def accounts_with_usage; end
    end
  end
end
