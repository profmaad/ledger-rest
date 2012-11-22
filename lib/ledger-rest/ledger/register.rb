module LedgerRest
  class Ledger
    class Register

      FORMAT = [
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

      class << self

        def get(query = nil, params = {})
          JSON.parse(json(query, params), :symbolize_names => true)
        end

        def json(query = nil, params = {})
          params = { '--format' => FORMAT }.merge(params)
          result = Ledger.exec("reg #{query}", params)
          result << "\n]\n}"
          result.gsub! /\},\n *?\]/m, "}\n     \]"

          "{\"transactions\":[#{result}]}"
        end

      end
    end
  end
end
