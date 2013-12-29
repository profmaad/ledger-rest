# -*- coding: utf-8 -*-
module LedgerRest
  class Ledger
    class Balance
      FORMAT = [
                '{',
                '"totals":[[%(quoted(scrub(display_total)))]],',
                '"name":%(quoted(partial_account)),',
                '"depth":%(depth), "fullname": %(quoted(account))',
                '},%/],',
                '"totals":[[%(quoted(scrub(display_total)))]]'
               ].join

      class << self
        def get(query = nil, params = {})
          data = JSON.parse(json(query, params), symbolize_names: true)

          data[:accounts] = expand_accounts(data[:accounts])
          unless query =~ /--flat/
            data[:accounts] = wrap_accounts(data[:accounts])
          end

          data
        end

        def json(query = nil, params = {})
          params = { '--format' => FORMAT }.merge(params)
          puts "bal #{query}"
          result = Ledger.exec("bal #{query}", params)

          parser = Ledger::Parser.new
          result.gsub! /\[\["(?<amounts>[^"]+)"\]\]/m do |a, b|
            $~[:amounts].split("\n").map do |str|
              amount, commodity = parser.parse_amount_parts(str)
              { amount: amount, commodity: commodity }
            end.to_json
          end
          "{\"accounts\":[#{result.gsub(',]', ']')}}"
        end

        def expand_accounts(accounts)
          accounts.inject([]) do |acc, elem|
            fullname = elem[:fullname].gsub(/:?#{elem[:name]}/, '')
            acc + elem[:name].split(':').map do |name|
              fullname << "#{':' unless fullname.empty?}#{name}"
              parent = elem.dup
              parent[:fullname], parent[:name], parent[:depth] =
                fullname.dup, name.dup, fullname.count(':')+1
              parent
            end
          end
        end

        def wrap_accounts(accounts)
          stack = []
          accounts.inject([]) do |acc, elem|
            stack.pop while stack.last && stack.last[:depth] >= elem[:depth]
            if stack.empty?
              stack << elem
              acc << elem
            else
              (stack.last[:accounts] ||= []) << elem
              stack << elem
            end
            acc
          end
        end
      end
    end
  end
end
