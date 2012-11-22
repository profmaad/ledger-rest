module LedgerRest
  class Ledger
    class Transaction < Hash

      # Create a new transaction and append it to the append file.
      def self.create(params)

      end

      def verify
        result = IO.popen("#{settings.ledger_bin} -f - stats 2>&1", "r+") do |f|
          f.write self.to_ledger
          f.close_write
          f.readlines
        end

        $?.success? and not result.empty?
      end

      def to_ledger
        if(
           transaction[:date].nil? or
           transaction[:payee].nil? or
           transaction[:postings].nil?
           )
          return nil
        end

        result = ""

        result += transaction[:date]
        result += "="+transaction[:effective_date] unless transaction[:effective_date].nil?

        if transaction[:cleared]
          result += " *"
        elsif transaction[:pending]
          result += " !"
        end

        result += " ("+transaction[:code]+")" unless transaction[:code].nil?
        result += " "+transaction[:payee]
        result += "\n"

        transaction[:postings].each do |posting|
          if(posting[:comment])
            result += "  ; "+posting[:comment]+"\n"
            next
          end

          next if posting[:account].nil?

          result += "  "
          result += posting[:account]

          if posting[:amount].nil?
            result += "\n"
            next
          end

          result += "  "+posting[:amount]

          if(posting[:per_unit_cost])
            result += " @ "+posting[:per_unit_cost]
          elsif(posting[:posting_cost])
            result += " @@ "+posting[:posting_cost]
          end

          unless(posting[:actual_date].nil? and posting[:effective_date].nil?)
            result += "  ; ["
            result += posting[:actual_date] unless posting[:actual_date].nil?
            result += "="+posting[:effective_date] unless posting[:effective_date].nil?
            result += "]"
          end

          result += "\n"
        end

        result += "\n"

        return result
      end
    end
  end
end
