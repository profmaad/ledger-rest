# -*- coding: utf-8 -*-
require 'spec_helper'

describe '/balance' do
  context 'normally' do
    let(:valid_json) do
      {
        'accounts' =>
        [
         {
           'total'    => '3177.80EUR',
           'name'     => 'Assets',
           'depth'    => 1,
           'fullname' => 'Assets',
           'accounts' =>
           [
            {
              'total'    => '5.70EUR',
              'name'     => 'Cash',
              'depth'    => 2,
              'fullname' => 'Assets:Cash'
            },
            {
              'total'    => '3150.00EUR',
              'name'     => 'Giro',
              'depth'    => 2,
              'fullname' => 'Assets:Giro'
            },
            {
              'total'    => '22.10EUR',
              'name'     => 'Reimbursements',
              'depth'    => 2,
              'fullname' => 'Assets:Reimbursements',
              'accounts' =>
              [
               {
                 'total'    => '22.10EUR',
                 'name'     => 'Hans Maulwurf',
                 'depth'    => 3,
                 'fullname' => 'Assets:Reimbursements:Hans Maulwurf'
               }
              ]
            }
           ]
         },
         {
           'total'    => '-12.00EUR',
           'name'     => 'Liabilities',
           'depth'    => 1,
           'fullname' => 'Liabilities',
           'accounts' =>
           [
            {
              'total'    => '-12.00EUR',
              'name'     => 'Max Mustermann',
              'depth'    => 2,
              'fullname' => 'Liabilities:Max Mustermann'
            }
           ]
         }
        ],
        'total' => '3165.80EUR'
      }
    end

    it 'expands and wraps accounts' do
      get '/balance', query: 'Assets Liabilities'
      JSON.parse(last_response.body).should deep_eq valid_json
    end
  end

  context 'with --flat query' do
    let(:valid_json) do
      {
        'accounts' =>
        [
         {
           'total'    => '5.70EUR',
           'name'     => 'Cash',
           'depth'    => 2,
           'fullname' => 'Assets:Cash'
         }, {
           'total'    => '3150.00EUR',
           'name'     => 'Giro',
           'depth'    => 2,
           'fullname' => 'Assets:Giro'
         }, {
           'total'    => '22.10EUR',
           'name'     => 'Reimbursements',
           'depth'    => 2,
           'fullname' => 'Assets:Reimbursements'
         }, {
           'total'    => '22.10EUR',
           'name'     => 'Hans Maulwurf',
           'depth'    => 3,
           'fullname' => 'Assets:Reimbursements:Hans Maulwurf'
         }, {
           'total'    => '-12.00EUR',
           'name'     => 'Liabilities',
           'depth'    => 1,
           'fullname' => 'Liabilities'
         }, {
           'total'    => '-12.00EUR',
           'name'     => 'Max Mustermann',
           'depth'    => 2,
           'fullname' => 'Liabilities:Max Mustermann' }
        ],
        'total' => '3165.80EUR'
      }
    end

    it 'does not wrap accounts' do
      get '/balance', query: '--flat Assets Liabilities'
      JSON.parse(last_response.body).should deep_eq valid_json
    end
  end
end
