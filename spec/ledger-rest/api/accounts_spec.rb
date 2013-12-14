# -*- coding: utf-8 -*-
require 'spec_helper'

describe '/accounts' do
  it 'returns accounts' do
    get '/accounts'

    JSON.parse(last_response.body).should ==
      [
       'Assets:Cash',
       'Assets:Giro',
       'Assets:Reimbursements:Hans Maulwurf',
       'Equity:Opening Balances',
       'Expenses:Restaurants',
       'Liabilities:Max Mustermann'
      ]
  end
end
