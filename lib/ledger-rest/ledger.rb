# -*- coding: utf-8 -*-
module LedgerRest
  class Ledger
    class << self

      BUDGET_FORMAT = [
                       '{',
                       '        "name": %(quoted(account)),',
                       '        "amount": %(quoted(get_at(T, 0))),',
                       '        "budget": %(quoted(-get_at(T, 1)))',
                       '      },%/',
                       '    ],',
                       '    "total_amount": %(quoted(get_at(T, 0))),',
                       '    "total_budget": %(quoted(-get_at(T, 1)))'
                      ].join('\\n')

      REGISTER_FORMAT = [
                         "{",
                         '  "date": %(quoted(date)),',
                         '  "effective_date": %(effective_date ? quoted(effective_date) : "null"),',
                         '  "code": %(code ? quoted(code) : "null"),',
                         '  "cleared": %(cleared ? "true" : "false"),',
                         '  "pending": %(pending ? "true" : "false"),',
                         '  "payee": %(quoted(payee)),',
                         '  "postings":',
                         '    [',
                         '      { "account": %(quoted(display_account)), "amount": %(quoted(amount)) },%/',
                         '      { "account": %(quoted(display_account)), "amount": %(quoted(amount)) },%/',
                         '    ]',
                         '},'
                        ].join('\\n')

      BALANCE_FORMAT = [
                        '{',
                        '  "total": %(quoted(display_total)),',
                        '  "name": %(quoted(partial_account)),',
                        '  "depth": %(depth), "fullname": %(quoted(account))',
                        '},%/',
                        '{ "total": %(quoted(display_total)) }'
                       ].join('\\n')

      EXAMPLE_TRANSACTION = {
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

      attr_accessor :rcfile, :bin, :file, :append_file, :home

      def configure(options)
        @bin = options[:ledger_bin] || "/usr/bin/ledger"
        @file = options[:ledger_file] || ENV['LEDGER_FILE']
        @append_file = options[:ledger_append_file] || ENV['LEDGER_FILE']
        @home = options[:ledger_home] || ''
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

      # Return a Hash representations of the balance result.
      def register query = nil
        result = exec "reg #{query if query}", '--format' => REGISTER_FORMAT
        result << "\n]\n}"
        result.gsub! /\},\n *?\]/m, "}\n     \]"

        json_str = "{\"transactions\":[#{result}]}"

        JSON.parse json_str, :symbolize_names => true
      end

      # Return a Hash representations of the balance result.
      def balance query = nil
        result = exec "bal #{query if query}", '--format' => BALANCE_FORMAT

        total = nil
        if result.end_with?(',')
          result = result[0..-2]
        else
          match_total = result.match(/,\n.*?{ +"total": +("[0-9\.A-Za-z ]+") +}\z/)
          if match_total
            total = match_total[1]
            result = result[0,match_total.offset(0)[0]]
          end
        end

        json_str = "{"
        json_str << " \"accounts\": [ #{result} ]"
        json_str << ", \"total\": #{total}" if total
        json_str << " }"
        JSON.parse(json_str, :symbolize_names => true)
      end

      # Get a new transaction entry based on previous entries found
      # in the append file.
      def entry description
        result = exec "entry #{description}", '-f' => append_file


      end

      # Return a budget hash representation.
      def budget(query = nil)
        result = exec "budget #{query if query}", '--format' => BUDGET_FORMAT
        result.gsub! /\},\n *?\]/, "}\n  ]"

        json_str = "{\n  \"budget\": {\n    \"accounts\": [\n      #{result}\n  }\n}"

        JSON.parse json_str, :symbolize_names => true
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
