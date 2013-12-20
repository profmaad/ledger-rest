# -*- coding: utf-8 -*-
module LedgerRest
  class Ledger
    class Budget
      FORMAT = [
                '%(scrub(get_at(display_total, 0)))\n',
                '%(-scrub(get_at(display_total, 1)))\n',
                '%(scrub(get_at(display_total, 1) + get_at(display_total, 0)))\n',
                '%(get_at(display_total, 1) ? (100% * scrub(get_at(display_total, 0))) / -scrub(get_at(display_total, 1)) : 0)\n',
                '%(account)\n',
                '---\n',
                '%/---\n',
                '%$1\n',
                '%$2\n',
                '%$3\n',
                '%$4\n',
                '%/'
               ].join

      class << self
        def get(query = nil, params = {})
          JSON.parse(json(query, params), symbolize_names: true)
        end

        def json(query = nil, params = {})
          params = { '--format' => FORMAT }.merge(params)
          result = Ledger.exec("budget #{query}", params)
          budget = {}
          accounts, total = result.split("---\n---\n")
          budget['accounts'] = accounts.split("---\n").map do |str|
            val = str.split("\n")
            {
              'total'      => val[0].empty? ? '0' : val[0],
              'budget'     => val[1].empty? ? '0' : val[1],
              'difference' => val[2].empty? ? '0' : val[2],
              'percentage' => val[3].empty? ? '0' : val[3],
              'account'    => val[4].empty? ? '0' : val[4]
            }
          end
          if total
            val = total.split("\n")
            budget['total']      = val[0].empty? ? '0' : val[0]
            budget['budget']     = val[1].empty? ? '0' : val[1]
            budget['difference'] = val[2].empty? ? '0' : val[2]
            budget['percentage'] = val[3].empty? ? '0' : val[3]
          end
          budget.to_json
        end
      end
    end
  end
end
