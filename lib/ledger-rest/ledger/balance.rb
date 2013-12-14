# -*- coding: utf-8 -*-
module LedgerRest
  class Ledger
    class Balance
      FORMAT = [
                '{',
                '  "total": %(quoted(display_total)),',
                '  "name": %(quoted(partial_account)),',
                '  "depth": %(depth), "fullname": %(quoted(account))',
                '},%/',
                '{ "total": %(quoted(display_total)) }'
               ].join('\\n')

      class << self
        def get(query = nil, params = {})
          data = JSON.parse(json(query, params), symbolize_names: true)

          data[:accounts] = expand_accounts(data[:accounts])
          data[:accounts] = wrap_accounts(data[:accounts])

          data
        end

        def json(query = nil, params = {})
          params = { '--format' => FORMAT }.merge(params)
          result = Ledger.exec("bal #{query}", params)

          total = nil
          if result.end_with?(',')
            result = result[0..-2]
          else
            match_total = result.match(/,\n.*?{ +"total": +("[0-9\.A-Za-z ]+") +}\z/)
            if match_total
              total = match_total[1]
              result = result[0, match_total.offset(0)[0]]
            end
          end

          json_str = '{'
          json_str << " \"accounts\": [ #{result} ]"
          json_str << ", \"total\": #{total}" if total
          json_str << ' }'
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
