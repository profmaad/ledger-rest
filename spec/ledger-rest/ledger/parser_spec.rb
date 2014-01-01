# -*- coding: utf-8 -*-
require 'spec_helper'

describe LedgerRest::Ledger::Parser do
  before :all do
    @parser = LedgerRest::Ledger::Parser.new
  end

  describe '#parse' do
    subject do
      LedgerRest::Ledger::Transaction.new(date: '2012/03/01',
                                          effective_date: '2012/03/23',
                                          cleared: true,
                                          pending: false,
                                          code: 'INV#23',
                                          payee: 'me, myself and I',
                                          postings:
                                          [
                                           {
                                             account: 'Expenses:Imaginary',
                                             amount: 23.0,
                                             commodity: 'EUR',
                                             per_unit_cost: 2300.0,
                                             per_unit_commodity: 'USD',
                                             actual_date: '2012/03/24',
                                             effective_date: '2012/03/25'
                                           }, {
                                             account: 'Expenses:Magical',
                                             amount: 42.0,
                                             commodity: 'EUR',
                                             posting_cost: 23000000.0,
                                             posting_cost_commodity: 'USD',
                                             virtual: true
                                           }, {
                                             account: 'Assets:Mighty'
                                           }, {
                                             comment: 'This is a freeform comment'
                                           },
                                          ])
    end

    it 'should parse a to_ledger converted transaction into the same original hash' do
      @parser.parse(subject.to_ledger).should == subject
    end
  end

  describe '#parse_date' do
    before :all do
      @ret = @parser.parse_date("2012/11/23 * Rest with\nAnd Stuff")
    end

    it 'returns the parsed date' do
      @ret[0].should == '2012/11/23'
    end

    it 'returns the rest of the input' do
      @ret[1].should == " * Rest with\nAnd Stuff"
    end
  end

  describe '#parse_effective_date' do
    before :all do
      @ret = @parser.parse_effective_date("=2012/11/24 * Rest with\nAnd Stuff")
    end

    it 'returns the parsed date' do
      @ret[0].should == '2012/11/24'
    end

    it 'returns the rest of the input' do
      @ret[1].should == " * Rest with\nAnd Stuff"
    end
  end

  describe '#parse_state' do
    context 'given cleared transaction input' do
      before :all do
        @ret = @parser.parse_cleared(" * Rest with\nAnd Stuff")
      end

      it 'returns true' do
        @ret[0].should == true
      end

      it 'returns the rest of the input' do
        @ret[1].should == "Rest with\nAnd Stuff"
      end
    end

    context 'unspecified transaction input' do
      before :all do
        @ret = @parser.parse_cleared("Rest with\nAnd Stuff")
      end

      it 'returns false' do
        @ret[0].should == false
      end

      it 'returns the rest of the input' do
        @ret[1].should == "Rest with\nAnd Stuff"
      end
    end
  end

  describe '#parse_pending' do
    context 'given pending transaction input' do
      before :all do
        @ret = @parser.parse_pending(" ! Rest with\nAnd Stuff")
      end

      it 'returns true' do
        @ret[0].should == true
      end

      it 'returns the rest of the input' do
        @ret[1].should == "Rest with\nAnd Stuff"
      end
    end

    context 'unspecified transaction input' do
      before :all do
        @ret = @parser.parse_pending("Rest with\nAnd Stuff")
      end

      it 'returns false' do
        @ret[0].should == false
      end

      it 'returns the rest of the input' do
        @ret[1].should == "Rest with\nAnd Stuff"
      end
    end
  end

  describe '#parse_code' do
    context 'given a transaction with white-spaced code' do
      subject { @parser.parse_code(" (#123) Rest with\nAnd Stuff") }

      its(:first) { should == '#123' }
      its(:last) { should == "Rest with\nAnd Stuff" }
    end

    context 'given a transaction with code' do
      subject { @parser.parse_code("(#123) Rest with\nAnd Stuff") }

      its(:first) { should == '#123' }
      its(:last) { should == "Rest with\nAnd Stuff" }
    end

    context 'given a transaction without code' do
      subject { @parser.parse_code("Rest with\nAnd Stuff") }

      its(:first) { should be_nil }
      its(:last) { should == "Rest with\nAnd Stuff" }
    end
  end

  describe '#parse_payee' do
    context 'given an unstripped line' do
      subject { @parser.parse_payee("  Monsieur Le Payee\n  Some:Account  123EUR\n  Some:Other")}

      its(:first) { should == 'Monsieur Le Payee' }
      its(:last) { should == "  Some:Account  123EUR\n  Some:Other" }
    end

    context 'given a stripped line' do
      context 'given an unstripped line' do
        subject { @parser.parse_payee("Monsieur Le Payee\n  Some:Account  123EUR\n  Some:Other")}

        its(:first) { should == 'Monsieur Le Payee' }
        its(:last) { should == "  Some:Account  123EUR\n  Some:Other" }
      end
    end
  end

  describe '#parse_comments' do
    context 'given no comments' do
      subject { @parser.parse_comments('  Assets:Some:Stuff  23EUR')}

      it 'returns all comments' do
        subject[0].should be_nil
      end

      it 'returns the rest of the input' do
        subject[1].should == '  Assets:Some:Stuff  23EUR'
      end
    end

    context 'given one line of transaction comments' do
      subject { @parser.parse_comments("  ; ABC\n  Assets:Some:Stuff  23EUR")}

      it 'returns all comments' do
        subject[0].should == "ABC\n"
      end

      it 'returns the rest of the input' do
        subject[1].should == '  Assets:Some:Stuff  23EUR'
      end
    end

    context 'given multiple lines of transaction comments' do
      subject { @parser.parse_comments("  ; ABC\n  ;DEF\n  Assets:Some:Stuff  23EUR")}

      it 'returns all comments' do
        subject[0].should == "ABC\nDEF\n"
      end

      it 'returns the rest of the input' do
        subject[1].should == '  Assets:Some:Stuff  23EUR'
      end
    end
  end

  describe '#parse_account' do
    context 'given normal' do
      subject { @parser.parse_account("  Assets:Some:Nice  200EUR\n  Assets:Account")}

      it 'returns the account' do
        subject[0].should == 'Assets:Some:Nice'
      end

      it 'is not virtual' do
        subject[1].should == false
      end

      it 'is not balanced virtual' do
        subject[2].should == false
      end

      it 'returns the rest of the input' do
        subject[3].should == "200EUR\n  Assets:Account"
      end
    end

    context 'given input without amount' do
      subject { @parser.parse_account('  Assets:Some:Nice') }

      it 'returns the account' do
        subject[0].should == 'Assets:Some:Nice'
      end

      it 'is not virtual' do
        subject[1].should == false
      end

      it 'is not balanced virtual' do
        subject[2].should == false
      end

      it 'returns the rest of the input' do
        subject[3].should == ''
      end
    end

    context 'given virtual' do
      subject { @parser.parse_account("  (Assets:Some:Nice)  200EUR\n  Assets:Account")}

      it 'returns the account' do
        subject[0].should == 'Assets:Some:Nice'
      end

      it 'is not virtual' do
        subject[1].should == true
      end

      it 'is not balanced virtual' do
        subject[2].should == false
      end

      it 'returns the rest of the input' do
        subject[3].should == "200EUR\n  Assets:Account"
      end
    end

    context 'given balanced virtual' do
      subject { @parser.parse_account("  [Assets:Some:Nice]  200EUR\n  Assets:Account")}

      it 'returns the account' do
        subject[0].should == 'Assets:Some:Nice'
      end

      it 'is not virtual' do
        subject[1].should == true
      end

      it 'is not balanced virtual' do
        subject[2].should == true
      end

      it 'returns the rest of the input' do
        subject[3].should == "200EUR\n  Assets:Account"
      end
    end
  end

  describe '#parse_amount_parts' do
    context 'given "-23.00EUR"' do
      subject { @parser.parse_amount_parts('-23.00EUR') }

      it 'returns the value' do
        subject[0].should == -23.0
      end

      it 'returns the commodity' do
        subject[1].should == 'EUR'
      end
    end

    context 'given "EUR-23.00"' do
      subject { @parser.parse_amount_parts('EUR-23.00') }

      it 'returns the value' do
        subject[0].should == -23.0
      end

      it 'returns the commodity' do
        subject[1].should == 'EUR'
      end
    end

    context 'given "23.00EUR"' do
      subject { @parser.parse_amount_parts('23.00EUR') }

      it 'returns the value' do
        subject[0].should == 23.0
      end

      it 'returns the commodity' do
        subject[1].should == 'EUR'
      end
    end

    context 'given "23EUR"' do
      subject { @parser.parse_amount_parts('23EUR') }

      it 'returns the value' do
        subject[0].should == 23.0
      end

      it 'returns the commodity' do
        subject[1].should == 'EUR'
      end
    end

    context 'given "USD23"' do
      subject { @parser.parse_amount_parts('USD23') }

      it 'returns the value' do
        subject[0].should == 23.0
      end

      it 'returns the commodity' do
        subject[1].should == 'USD'
      end
    end

    context 'given "USD23.00"' do
      subject { @parser.parse_amount_parts('USD23') }

      it 'returns the value' do
        subject[0].should == 23.0
      end

      it 'returns the commodity' do
        subject[1].should == 'USD'
      end
    end

    context 'given "€ 23.00"' do
      subject { @parser.parse_amount_parts('€ 23.00') }

      it 'returns the value' do
        subject[0].should == 23.0
      end

      it 'returns the commodity' do
        subject[1].should == '€'
      end
    end
  end

  describe '#parse_amount' do
    context 'given "23.00EUR"' do
      subject { @parser.parse_amount('23.00EUR') }

      it 'returns amount and commodity' do
        subject[0].should == '23.00EUR'
      end

      it 'returns no posting_cost' do
        subject[1].should be_nil
      end

      it 'returns no per_unit_cost' do
        subject[2].should be_nil
      end
    end

    context 'given "25 AAPL @ 10.00EUR"' do
      subject { @parser.parse_amount('25 AAPL @ 10.00EUR') }

      it 'returns amount and commodity' do
        subject[0].should == '25 AAPL'
      end

      it 'returns correct posting_cost' do
        subject[1].should == '10.00EUR'
      end

      it 'returns no per_unit_cost' do
        subject[2].should be_nil
      end
    end

    context 'given "30Liters @@ 1.64EUR"' do
      subject { @parser.parse_amount('30Liters @@ 1.64EUR') }

      it 'returns amount and commodity' do
        subject[0].should == '30Liters'
      end

      it 'returns no posting_cost' do
        subject[1].should be_nil
      end

      it 'returns correct per_unit_cost' do
        subject[2].should == '1.64EUR'
      end
    end
  end

  describe '#parse_posting' do
    context 'given posting with comment' do
      subject { @parser.parse_posting("  Assets:Test:Account  123EUR\n  ; Some comment") }

      it 'has parsed correctly' do
        subject.should == {
          account: 'Assets:Test:Account',
          amount: 123.0,
          commodity: 'EUR'
        }
      end
    end

    context 'given source posting' do
      subject { @parser.parse_posting('  Assets:Test:Account') }

      it 'has parsed correctly' do
        subject.should == {
          account: 'Assets:Test:Account'
        }
      end
    end
  end
end
