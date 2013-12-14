# -*- coding: utf-8 -*-
module LedgerRest
  class Ledger
    class Register
      class << self
        def format(query)
          format = '{'
          if query =~ /-D|--daily|-W|--weekly|-M|--monthly|--quarterly|-Y|--yearly/
            format << '"beginning": %(quoted(format_date(date))),'
            format << '"end": %(quoted(payee)),'
          else
            format << '"date": %(quoted(format_date(date))),'
            format << '"effective_date": %(effective_date ? quoted(effective_date) : "null"),'
            format << '"code": %(code ? quoted(code) : "null"),'
            format << '"cleared": %(cleared ? "true" : "false"),'
            format << '"pending": %(pending ? "true" : "false"),'
            format << '"payee": %(quoted(payee)),'
          end
          format << '"postings": ['
          format << '{ "account": %(quoted(display_account)), "amount": %(quoted(quantity(scrub(display_amount)))), "total": %(quoted(quantity(scrub(display_amount)))), "commodity": %(quoted(commodity)) },%/'
          format << '{ "account": %(quoted(display_account)), "amount": %(quoted(quantity(scrub(display_amount)))), "total": %(quoted(quantity(scrub(display_amount)))), "commodity": %(quoted(commodity)) },%/'
          format << ']},'
          format
        end

        def get(query = nil, params = {})
          JSON.parse(json(query, params), symbolize_names: true)
        end

        def json(query = nil, params = {})
          params = {
            '--format' => format(query),
            '--date-format' => '%Y-%m-%d'
          }.merge(params)
          result = Ledger.exec("reg #{query}", params)
          result << "\n]\n}"
          result.gsub! '"end": "- ', '"end": "'
          result.gsub! /\},\n? *?\]/m, "}]"
          "[#{result}]"
        end
      end
    end
  end
end
