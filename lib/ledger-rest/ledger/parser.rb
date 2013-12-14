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

        @transaction[:date], str = parse_date(str)

        effective_date, str = parse_effective_date(str)
        @transaction[:effective_date] = effective_date if effective_date

        @transaction[:cleared], str = parse_cleared(str)
        @transaction[:pending], str = parse_pending(str)

        code, str = parse_code(str)
        @transaction[:code] = code if code

        @transaction[:payee], str = parse_payee(str)

        comments, str = parse_comments(str)
        @transaction[:comments] = comments if comments

        str.split("\n").each do |line|
          posting = parse_posting(line)
          @transaction[:postings] << posting
        end

        @transaction
      rescue Exception => e
        puts e
        puts "In: \n#{@str}"
      end

      def parse_date(str)
        if match = str.match(%r{\A(\d{4}/\d{1,2}/\d{1,2})(.*)}m)
          [match[1], match[2]]
        else
          fail 'Date was expected.'
        end
      end

      def parse_effective_date(str)
        if match = str.match(%r{\A=(\d{4}/\d{1,2}/\d{1,2})(.*)}m)
          [match[1], match[2]]
        else
          [nil, str]
        end
      end

      def parse_pending(str)
        if match = str.match(/\A ! (.*)/m)
          [true, match[1]]
        else
          [false, str]
        end
      end

      def parse_cleared(str)
        if match = str.match(/\A \* (.*)/m)
          [true, match[1]]
        else
          [false, str]
        end
      end

      def parse_code(str)
        if match = str.match(/\A *?\(([^\(\)]+)\) (.*)/m)
          [match[1], match[2]]
        else
          [nil, str]
        end
      end

      def parse_payee(str)
        if match = str.match(/\A *?([^ ][^\n]+)\n(.*)/m)
          [match[1], match[2]]
        else
          fail 'No payee given.'
        end
      end

      def parse_comments(str)
        comments = ''
        while str && match = str.match(/\A +;(.*?)(\n|$)(.*)/m)
          comments << match[1].strip << "\n"
          str = match[3]
        end
        [comments.empty? ? nil : comments, str]
      end

      # parses a ledger posting line
      def parse_posting(str)
        posting = {}

        account, virtual, balanced, str = parse_account(str)
        posting[:account] = account if account
        posting[:virtual] = virtual if virtual
        posting[:balanced] = balanced if balanced

        amount, posting_cost, per_unit_cost, str = parse_amount(str)
        posting[:amount] = amount if amount
        posting[:posting_cost] = posting_cost if posting_cost
        posting[:per_unit_cost] = per_unit_cost if per_unit_cost

        comment, actual_date, effective_date = parse_posting_comment(str)
        posting[:comment] = comment if comment
        posting[:actual_date] = actual_date if actual_date
        posting[:effective_date] = effective_date if effective_date

        posting
      end

      def parse_account(str)
        return [] if str.nil? || str.empty?
        if match = str.match(/\A +([\w:]+)(\n|$|  )(.*)/m)
          [match[1], false, false , match[3]]
        elsif match = str.match(/\A +\(([\w:]+)\)(\n|$|  )(.*)/m)
          [match[1], true, false , match[3]]
        elsif match = str.match(/\A +\[([\w:]+)\](\n|$|  )(.*)/m)
          [match[1], true, true , match[3]]
        else
          [nil, false, false, str]
        end
      end

      def parse_amount(str)
        if match = str.match(/\A(.*?)@@([^;]*?)(;(.*)|\n(.*)|$(.*))/m)
          amount = match[1].strip
          [amount.empty? ? nil : amount, nil, match[2].strip, match[3]]
        elsif match = str.match(/\A(.*?)@([^;]*)(;(.*)|\n(.*)|$(.*))/m)
          amount = match[1].strip
          [amount.empty? ? nil : amount, match[2].strip, nil, match[3]]
        elsif match = str.match(/\A([^;]*?)(;(.*)|\n(.*)|$(.*))/m)
          amount = match[1].strip
          [amount.empty? ? nil : amount, nil, nil, match[2]]
        end
      end

      def parse_posting_comment(str)
        comment, actual_date, effective_date = nil, nil, nil

        if match = str.match(/\A *?; \[(.*)\]/)
          actual_date, effective_date = match[1].split('=')
        elsif match = str.match(/\A *?; (.*)/)
          comment = match[1]
        end

        [comment, actual_date, effective_date]
      end
    end
  end
end
