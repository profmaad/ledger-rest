# -*- coding: utf-8 -*-
module LedgerRest
  class Ledger

    # A very simple parser for single legder format transactions.
    # There has to be a better way ... This does not implement the
    # whole ledger format. Tragically ... someone told me it´s the
    # essence of evil to do parser duplication. We need to use the
    # ledger parser. Maybe we can use the ledger code base and
    # integrate it into a ruby gem ... I don´t know.
    #
    # This works for `ledger entry` with my transactions ...
    class Parser

      class << self

        def parse(str)
          parser = Parser.new
          parser.parse(str)
        end

      end

      def initialize
        @transaction = Transaction.new
      end

      # Begins to parse a whole
      def parse(str)
        @str = str
        @transaction[:postings] = []

        @transaction[:date],str = parse_date(str)
        @transaction[:effective_date],str = parse_effective_date(str)
        @transaction[:cleared],str = parse_cleared(str)
        @transaction[:pending],str = parse_pending(str)
        @transaction[:code],str = parse_code(str)
        @transaction[:payee],str = parse_payee(str)

        comments,str = parse_comments(str)
        @transaction[:comments] = comments if comments

        while result = parse_posting(str)
          posting, str = result
          @transaction[:postings] << posting
        end

        @transaction
      rescue Exception => e
        puts e
        puts "In: \n#{@str}"
      end

      def parse_date(str)
        if match = str.match(/\A(\d{4}\/\d{1,2}\/\d{1,2})(.*)/m)
          [ match[1], match[2] ]
        else
          raise "Date was expected."
        end
      end

      def parse_effective_date(str)
        if match = str.match(/\A=(\d{4}\/\d{1,2}\/\d{1,2})(.*)/m)
          [ match[1], match[2] ]
        else
          [ nil, str ]
        end
      end

      def parse_pending(str)
        if match = str.match(/\A ! (.*)/m)
          [ true, match[1] ]
        else
          [ false, str]
        end
      end

      def parse_cleared(str)
        if match = str.match(/\A \* (.*)/m)
          [ true, match[1] ]
        else
          [ false, str]
        end
      end

      def parse_code(str)
        if match = str.match(/\A *?\(([^\(\)]+)\) (.*)/m)
          [ match[1], match[2] ]
        else
          [ nil, str ]
        end
      end

      def parse_payee(str)
        if match = str.match(/\A *?([^ ][^\n]+)\n(.*)/m)
          [ match[1], match[2] ]
        else
          raise "No payee given."
        end
      end

      def parse_comments(str)
        comments = ""
        while str && match = str.match(/\A +;(.*?)(\n|$)(.*)/m)
          comments << match[1].strip << "\n"
          str = match[3]
        end
        [ comments.empty? ? nil : comments, str ]
      end

      # parses a ledger posting line
      def parse_posting(str)
        posting = {}
        posting[:account], posting[:virtual], posting[:balanced], str = parse_account(str)
        return nil if posting[:account].nil?

        amount,posting_cost,per_unit_cost,str = parse_amount(str)
        posting[:amount] = amount if amount
        posting[:posting_cost] = posting_cost if posting_cost
        posting[:per_unit_cost] = per_unit_cost if per_unit_cost

        comments, str = parse_comments(str)
        posting[:comments] = comments if comments

        [ posting, str ]
      end

      def parse_account(str)
        return [] if str.nil? or str.empty?
        if match = str.match(/\A +([\w:]+)(\n|$|  )(.*)/m)
          [ match[1], false, false , match[3] ]
        elsif match = str.match(/\A +\(([\w:]+)\)(\n|$|  )(.*)/m)
          [ match[1], true, false , match[3] ]
        elsif match = str.match(/\A +\[([\w:]+)\](\n|$|  )(.*)/m)
          [ match[1], true, true , match[3] ]
        else
          raise "Error parsing account name for posting. #{str.inspect}"
        end
      end

      def parse_amount(str)
        if match = str.match(/\A(.*?)@@(.*?)(\n|$)(.*)/m)
          amount = match[1].strip
          [ amount.empty? ? nil : amount, nil, match[2].strip, match[4] ]
        elsif match = str.match(/\A(.*?)@(.*?)(\n|$)(.*)/m)
          amount = match[1].strip
          [ amount.empty? ? nil : amount, match[2].strip, nil, match[4] ]
        elsif match = str.match(/\A(.*?)(\n|$)(.*)/m)
          amount = match[1].strip
          [ amount.empty? ? nil : amount, nil, nil, match[3] ]
        end
      end

    end
  end
end
