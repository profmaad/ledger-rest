# -*- coding: utf-8 -*-
module LedgerRest
  class Ledger
    # Ledger offers a simple command to create a new entry based on
    # previous entries in your ledger files. This class abstracts
    # mentioned functionality for easy integration into ledger-rest.
    class Entry
      class << self
        # Return a new transaction object based on previous transactions.
        def get(desc, options = {})
          result = Ledger.exec("entry #{desc}", options)
          Transaction.parse(result)
        end

        # Appends a new transaction
        def append(desc, options = {})
          transaction = get(desc, options)
          transaction.append_to(Ledger.append_file)
          transaction
        end
      end
    end
  end
end
