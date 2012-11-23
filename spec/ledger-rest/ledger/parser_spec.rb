# -*- coding: utf-8 -*-
require 'spec_helper'

describe LedgerRest::Ledger::Parser do
  before :all do
    @parser = LedgerRest::Ledger::Parser.new
  end

  context '#parse' do
    subject {
      LedgerRest::Ledger::Transaction.new(:date => "2012/03/01",
                                          :effective_date => "2012/03/23",
                                          :cleared => true,
                                          :pending => false,
                                          :code => "INV#23",
                                          :payee => "me, myself and I",
                                          :postings => [
                                                        {
                                                          :account => "Expenses:Imaginary",
                                                          :amount => "€ 23",
                                                          :per_unit_cost => "USD 2300",
                                                          :actual_date => "2012/03/24",
                                                          :effective_date => "2012/03/25"
                                                        }, {
                                                          :account => "Expenses:Magical",
                                                          :amount => "€ 42",
                                                          :posting_cost => "USD 23000000",
                                                          :virtual => true
                                                        }, {
                                                          :account => "Assets:Mighty"
                                                        }, {
                                                          :comment => "This is a freeform comment"
                                                        },
                                                       ])
    }

    it 'should parse a to_ledger converted transaction into the same original hash' do
      @parser.parse(subject.to_ledger).should == subject
    end

  end

  context '#parse_date' do
    before :all do
      @ret = @parser.parse_date("2012/11/23 * Rest with\nAnd Stuff")
    end

    it 'should return the parsed date' do
      @ret[0].should == '2012/11/23'
    end

    it 'should return the rest of the input' do
      @ret[1].should == " * Rest with\nAnd Stuff"
    end
  end

  context '#parse_effective_date' do
    before :all do
      @ret = @parser.parse_effective_date("=2012/11/24 * Rest with\nAnd Stuff")
    end

    it 'should return the parsed date' do
      @ret[0].should == "2012/11/24"
    end

    it 'should return the rest of the input' do
      @ret[1].should == " * Rest with\nAnd Stuff"
    end
  end

  context '#parse_state' do
    context 'given cleared transaction input' do
      before :all do
        @ret = @parser.parse_cleared(" * Rest with\nAnd Stuff")
      end

      it 'should return true' do
        @ret[0].should == true
      end

      it 'should return the rest of the input' do
        @ret[1].should == "Rest with\nAnd Stuff"
      end
    end

    context 'unspecified transaction input' do
      before :all do
        @ret = @parser.parse_cleared("Rest with\nAnd Stuff")
      end

      it 'should return false' do
        @ret[0].should == false
      end

      it 'should return the rest of the input' do
        @ret[1].should == "Rest with\nAnd Stuff"
      end
    end
  end

  context '#parse_pending' do
    context 'given pending transaction input' do
      before :all do
        @ret = @parser.parse_pending(" ! Rest with\nAnd Stuff")
      end

      it 'should return true' do
        @ret[0].should == true
      end

      it 'should return the rest of the input' do
        @ret[1].should == "Rest with\nAnd Stuff"
      end
    end

    context 'unspecified transaction input' do
      before :all do
        @ret = @parser.parse_pending("Rest with\nAnd Stuff")
      end

      it 'should return false' do
        @ret[0].should == false
      end

      it 'should return the rest of the input' do
        @ret[1].should == "Rest with\nAnd Stuff"
      end
    end
  end

  context '#parse_code' do
    context 'given a transaction with white-spaced code' do
      subject { @parser.parse_code(" (#123) Rest with\nAnd Stuff") }

      its(:first) { should == '#123' }
      its(:last) { should == "Rest with\nAnd Stuff"}
    end

    context 'given a transaction with code' do
      subject { @parser.parse_code("(#123) Rest with\nAnd Stuff") }

      its(:first) { should == '#123' }
      its(:last) { should == "Rest with\nAnd Stuff" }
    end

    context 'given a transaction without code' do
      subject { @parser.parse_code("Rest with\nAnd Stuff") }

      its(:first) { should == nil }
      its(:last) { should == "Rest with\nAnd Stuff" }
    end
  end

  context '#parse_payee' do
    context 'given an unstripped line' do
      subject { @parser.parse_payee("  Monsieur Le Payee\n  Some:Account  123EUR\n  Some:Other")}

      its(:first) { should == "Monsieur Le Payee" }
      its(:last) { should == "  Some:Account  123EUR\n  Some:Other"}
    end

    context 'given a stripped line' do
      context 'given an unstripped line' do
        subject { @parser.parse_payee("Monsieur Le Payee\n  Some:Account  123EUR\n  Some:Other")}

        its(:first) { should == "Monsieur Le Payee" }
        its(:last) { should == "  Some:Account  123EUR\n  Some:Other"}
      end
    end
  end

  context '#parse_comments' do
    context 'given no comments' do
      subject { @parser.parse_comments("  Assets:Some:Stuff  23EUR")}

      it 'should return all comments' do
        subject[0].should == nil
      end

      it 'should return the rest of the input' do
        subject[1].should == "  Assets:Some:Stuff  23EUR"
      end
    end

    context 'given one line of transaction comments' do
      subject { @parser.parse_comments("  ; ABC\n  Assets:Some:Stuff  23EUR")}

      it 'should return all comments' do
        subject[0].should == "ABC\n"
      end

      it 'should return the rest of the input' do
        subject[1].should == "  Assets:Some:Stuff  23EUR"
      end
    end

    context 'given multiple lines of transaction comments' do
      subject { @parser.parse_comments("  ; ABC\n  ;DEF\n  Assets:Some:Stuff  23EUR")}

      it 'should return all comments' do
        subject[0].should == "ABC\nDEF\n"
      end

      it 'should return the rest of the input' do
        subject[1].should == "  Assets:Some:Stuff  23EUR"
      end
    end
  end

  context '#parse_account' do
    context 'given normal' do
      subject { @parser.parse_account("  Assets:Some:Nice  200EUR\n  Assets:Account")}

      it 'should return the account' do
        subject[0].should == "Assets:Some:Nice"
      end

      it 'should not be virtual' do
        subject[1].should == false
      end

      it 'should not be balanced virtual' do
        subject[2].should == false
      end

      it 'should return the rest of the input' do
        subject[3].should == "200EUR\n  Assets:Account"
      end
    end

    context 'given input without amount' do
      subject { @parser.parse_account("  Assets:Some:Nice")}

      it 'should return the account' do
        subject[0].should == "Assets:Some:Nice"
      end

      it 'should not be virtual' do
        subject[1].should == false
      end

      it 'should not be balanced virtual' do
        subject[2].should == false
      end

      it 'should return the rest of the input' do
        subject[3].should == ""
      end
    end

    context 'given virtual' do
      subject { @parser.parse_account("  (Assets:Some:Nice)  200EUR\n  Assets:Account")}

      it 'should return the account' do
        subject[0].should == "Assets:Some:Nice"
      end

      it 'should not be virtual' do
        subject[1].should == true
      end

      it 'should not be balanced virtual' do
        subject[2].should == false
      end

      it 'should return the rest of the input' do
        subject[3].should == "200EUR\n  Assets:Account"
      end
    end

    context 'given balanced virtual' do
      subject { @parser.parse_account("  [Assets:Some:Nice]  200EUR\n  Assets:Account")}

      it 'should return the account' do
        subject[0].should == "Assets:Some:Nice"
      end

      it 'should not be virtual' do
        subject[1].should == true
      end

      it 'should not be balanced virtual' do
        subject[2].should == true
      end

      it 'should return the rest of the input' do
        subject[3].should == "200EUR\n  Assets:Account"
      end
    end
  end

  context '#parse_amount' do
    context 'given "23.00EUR"' do
      subject { @parser.parse_amount("23.00EUR") }

      it 'should return amount and commodity' do
        subject[0].should == "23.00EUR"
      end

      it 'should return no posting_cost' do
        subject[1].should == nil
      end

      it 'should return no per_unit_cost' do
        subject[2].should == nil
      end
    end

    context 'given "25 AAPL @ 10.00EUR"' do
      subject { @parser.parse_amount("25 AAPL @ 10.00EUR") }

      it 'should return amount and commodity' do
        subject[0].should == "25 AAPL"
      end

      it 'should return correct posting_cost' do
        subject[1].should == "10.00EUR"
      end

      it 'should return no per_unit_cost' do
        subject[2].should == nil
      end
    end

    context 'given "30Liters @@ 1.64EUR"' do
      subject { @parser.parse_amount("30Liters @@ 1.64EUR") }

      it 'should return amount and commodity' do
        subject[0].should == "30Liters"
      end

      it 'should return no posting_cost' do
        subject[1].should == nil
      end

      it 'should return correct per_unit_cost' do
        subject[2].should == "1.64EUR"
      end
    end
  end

  context '#parse_posting' do
    context 'given posting with comment' do
      subject { @parser.parse_posting("  Assets:Test:Account  123EUR\n  ; Some comment") }

      it 'should have parsed correctly' do
        subject.should == {
          :account => "Assets:Test:Account",
          :amount => "123EUR"
        }
      end
    end

    context 'given source posting' do
      subject { @parser.parse_posting("  Assets:Test:Account") }

      it 'should have parsed correctly' do
        subject.should == {
          :account => "Assets:Test:Account"
        }
      end
    end
  end
end
