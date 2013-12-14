require 'spec_helper'

describe LedgerRest::Ledger::Balance do
  describe '::expand_accounts' do
    let(:accounts) do
      [
       {
         fullname: 'Expenses',
         name: 'Expenses',
         depth: 1,
         total: '453.10EUR'
       },
       {
         fullname: 'Expenses:Groceries:Bread',
         name: 'Groceries:Bread',
         depth: 3,
         total: '3.10EUR'
       },
       {
         fullname: 'Assets:Cash',
         name: 'Assets:Cash',
         depth: 1,
         total: '200.00EUR'
       }
      ]
    end

    let(:expanded) do
      [
       { fullname: 'Expenses', name: 'Expenses', depth: 1, total: '453.10EUR' },
       { fullname: 'Expenses:Groceries', name: 'Groceries', depth: 2, total: '3.10EUR' },
       { fullname: 'Expenses:Groceries:Bread', name: 'Bread', depth: 3, total: '3.10EUR' },
       { fullname: 'Assets', name: 'Assets', depth: 1, total: '200.00EUR' },
       { fullname: 'Assets:Cash', name: 'Cash', depth: 2, total: '200.00EUR' }
      ]
    end

    it 'expands accounts correctly' do
      LedgerRest::Ledger::Balance.expand_accounts(accounts).should deep_eq expanded
    end
  end

  describe '::wrap_accounts' do
    let(:accounts) do
      [
       {
         fullname: 'Expenses',
         name: 'Expenses',
         depth: 1,
         total: '453.10EUR'
       },
       {
         fullname: 'Expenses:Groceries',
         name: 'Groceries',
         depth: 2,
         total: '3.10EUR'
       },
       {
         fullname: 'Expenses:Groceries:Bread',
         name: 'Bread',
         depth: 3,
         total: '3.10EUR'
       },
       {
         fullname: 'Expenses:Flat',
         name: 'Flat',
         depth: 2,
         total: '450.00EUR'
       },
       {
         fullname: 'Assets',
         name: 'Assets',
         depth: 1,
         total: '200.00EUR'
       }
      ]
    end

    let(:wrapped) do
      [
       {
         fullname: 'Expenses',
         name: 'Expenses',
         depth: 1,
         total: '453.10EUR',
         accounts:
         [
          {
            fullname: 'Expenses:Groceries',
            name: 'Groceries',
            depth: 2,
            total: '3.10EUR',
            accounts:
            [
             {
               fullname: 'Expenses:Groceries:Bread',
               name: 'Bread',
               depth: 3,
               total: '3.10EUR'
             }
            ]
          },
          {
            fullname: 'Expenses:Flat',
            name: 'Flat',
            depth: 2,
            total: '450.00EUR'
          }
         ]
       },
       {
         fullname: 'Assets',
         name: 'Assets',
         depth: 1,
         total: '200.00EUR'
       }
      ]
    end

    it 'wraps accounts correctly' do
      LedgerRest::Ledger::Balance.wrap_accounts(accounts).should deep_eq wrapped
    end
  end
end
