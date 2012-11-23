# -*- coding: utf-8 -*-
require 'spec_helper'

describe LedgerRest::Ledger::Transaction do

  context '#to_ledger' do
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

    it 'should generate correct ledger string' do
      subject.to_ledger.should == "2012/03/01=2012/03/23 * (INV#23) me, myself and I\n  Expenses:Imaginary  € 23 @@ USD 2300  ; [2012/03/24=2012/03/25]\n  (Expenses:Magical)  € 42 @ USD 23000000\n  Assets:Mighty\n\  ; This is a freeform comment\n\n"
    end

  end


end
