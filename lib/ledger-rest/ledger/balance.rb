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

        def get query = nil, params = {}
          JSON.parse(json(query, params), :symbolize_names => true)
        end

        def json query = nil, params = {}
          params = { '--format' => FORMAT }.merge(params)
          result = Ledger.exec("bal #{query}", params)

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
        end

      end
    end
  end
end
