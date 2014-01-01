require 'spec_helper'

describe LedgerRest::Ledger::Balance do
  describe '::get' do
    let(:json_with_root) do
      {
        accounts:
        [
         {
           totals: [{ amount: 0.25, commodity: 'BTC' }, { amount: 3022.97, commodity: 'EUR' }],
           name: 'Assets',
           depth: 1,
           fullname: 'Assets'
         }, {
           totals: [{ amount: 0.25, commodity: 'BTC' }],
           name: 'Bitcoin',
           depth: 2,
           fullname: 'Assets:Bitcoin'
         }, {
           totals: [{ amount: 5.7, commodity: 'EUR' }],
           name: 'Cash',
           depth: 2,
           fullname: 'Assets:Cash'
         }, {
           totals: [{ amount: 2995.17, commodity: 'EUR' }],
           name: 'Giro',
           depth: 2,
           fullname: 'Assets:Giro'
         }, {
           totals: [{ amount: 22.1, commodity: 'EUR' }],
           name: 'Reimbursements',
           depth: 2,
           fullname: 'Assets:Reimbursements'
         }, {
           totals: [{ amount: 22.1, commodity: 'EUR' }],
           name: 'Hans Maulwurf',
           depth: 3,
           fullname: 'Assets:Reimbursements:Hans Maulwurf'
         }
        ],
        totals: [{ amount: 0.25, commodity: 'BTC' }, { amount: 3022.97, commodity: 'EUR' }]
      }
    end

    it 'removes the --flat flag from ledger command to gather root accounts aswell' do
      LedgerRest::Ledger::Balance.get('--flat Assets').should deep_eq json_with_root
    end
  end

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
