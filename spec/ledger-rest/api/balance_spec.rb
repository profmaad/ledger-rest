# -*- coding: utf-8 -*-
require 'spec_helper'

describe '/balance' do
  let(:valid_json) do
    {
      "accounts" =>
      [
       {
         "total" => "1977.80EUR",
         "name" => "Assets",
         "depth" => 1,
         "fullname" => "Assets",
         "accounts"=>
         [
          {
            "total" => "5.70EUR",
            "name" => "Cash",
            "depth" => 2,
            "fullname" => "Assets:Cash"
          },
          {
            "total" => "1950.00EUR",
            "name" => "Giro",
            "depth" => 2,
            "fullname" => "Assets:Giro"
          },
          {
            "total" => "22.10EUR",
            "name" => "Reimbursements",
            "depth" => 2,
            "fullname" => "Assets:Reimbursements",
            "accounts" =>
            [
             { "total" => "22.10EUR",
               "name" => "Hans Maulwurf",
               "depth" => 3,
               "fullname" => "Assets:Reimbursements:Hans Maulwurf"}
            ]
          }
         ]
       },
       {
         "total" => "-2019.00EUR",
         "name" => "Equity",
         "depth" => 1,
         "fullname" => "Equity",
         "accounts" =>
         [
          {
            "total" => "-2019.00EUR",
            "name" => "Opening Balances",
            "depth" => 2,
            "fullname" => "Equity:Opening Balances"
          }
         ]
       },
       {
         "total" => "53.20EUR",
         "name" => "Expenses",
         "depth" => 1,
         "fullname" => "Expenses",
         "accounts" =>
         [
          {
            "total" => "53.20EUR",
            "name" => "Restaurants",
            "depth" => 2,
            "fullname" => "Expenses:Restaurants"
          }
         ]
       },
       {
         "total" => "-12.00EUR",
         "name" => "Liabilities",
         "depth" => 1,
         "fullname" => "Liabilities",
         "accounts" =>
         [
          {
            "total" => "-12.00EUR",
            "name" => "Max Mustermann",
            "depth" => 2,
            "fullname" => "Liabilities:Max Mustermann"
          }
         ]
       }
      ],
      "total" => "0"
    }
  end

  it 'returns the balance as JSON' do
    get '/balance'
    JSON.parse(last_response.body).should deep_eq valid_json
  end
end
