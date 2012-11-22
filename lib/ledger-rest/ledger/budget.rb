module LedgerRest
  class Ledger
    class Budget
      FORMAT = [
                '{',
                '        "name": %(quoted(account)),',
                '        "amount": %(quoted(get_at(T, 0))),',
                '        "budget": %(quoted(-get_at(T, 1)))',
                '      },%/',
                '    ],',
                '    "total_amount": %(quoted(get_at(T, 0))),',
                '    "total_budget": %(quoted(-get_at(T, 1)))'
               ].join('\\n')

      class << self

        def get(query = nil, params = {})
          JSON.parse(json(query, params), :symbolize_names => true)
        end

        def json(query = nil, params = {})
          params = { '--format' => FORMAT }.merge(params)
          result = Ledger.exec("budget #{query}", params)
          result.gsub!(/\},\n *?\]/, "}\n  ]")

          "{\n  \"budget\": {\n    \"accounts\": [\n      #{result}\n  }\n}"
        end

      end

    end
  end
end
