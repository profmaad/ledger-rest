# -*- coding: utf-8 -*-
require 'spec_helper'

describe LedgerRest::Ledger::Transaction do
  context '#to_ledger' do
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

    it 'should generate correct ledger string' do
      subject.to_ledger.should == <<TRANSACTION
2012/03/01=2012/03/23 * (INV#23) me, myself and I
    Expenses:Imaginary  23.00EUR @@ 2300.00USD  ; [2012/03/24=2012/03/25]
    (Expenses:Magical)  42.00EUR @ 23000000.00USD
    Assets:Mighty
    ; This is a freeform comment
TRANSACTION
    end
  end
end
