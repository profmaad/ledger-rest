# -*- coding: utf-8 -*-
module LedgerRest
  class Ledger
    class Transaction < Hash

      class << self

        # Parse a ledger transaction string into a `Transaction` object.
        def parse(str)
          LedgerRest::Ledger::Parser.parse(str)
        end

      end

      def initialize(params = {})
        self.merge!(params)
      end

      # Return true if the `Transaction#to_ledger` is a valid ledger string.
      def valid?
        result = IO.popen("#{settings.ledger_bin} -f - stats 2>&1", "r+") do |f|
          f.write self.to_ledger
          f.close_write
          f.readlines
        end

        $?.success? and not result.empty?
      end

      def to_ledger
        if self[:date].nil? or
            self[:payee].nil? or
            self[:postings].nil?
          return nil
        end

        result = ""

        result << self[:date]
        result << "=#{self[:effective_date]}" if self[:effective_date]

        if self[:cleared]
          result << " *"
        elsif self[:pending]
          result << " !"
        end

        result << " (#{self[:code]})" if self[:code]
        result << " #{self[:payee]}"
        result << "\n"

        self[:postings].each do |posting|
          if posting[:comment]
            result << "  ; #{posting[:comment]}\n"
            next
          end

          next unless posting[:account]

          if posting[:virtual]
            if posting[:balance]
              result << "  [#{posting[:account]}]"
            else
              result << "  (#{posting[:account]})"
            end
          else
            result << "  #{posting[:account]}"
          end

          if posting[:amount].nil?
            result << "\n"
            next
          end

          result << "  #{posting[:amount]}"

          if(posting[:per_unit_cost])
            result << " @@ #{posting[:per_unit_cost]}"
          elsif(posting[:posting_cost])
            result << " @ #{posting[:posting_cost]}"
          end

          if posting[:actual_date] or posting[:effective_date]
            result << "  ; ["
            result << posting[:actual_date] if posting[:actual_date]
            result << "=#{posting[:effective_date]}" if posting[:effective_date]
            result << "]"
          end

          result << "\n"
        end

        result << "\n"

        result
      end
    end
  end
end
