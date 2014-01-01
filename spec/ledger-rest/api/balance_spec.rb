# -*- coding: utf-8 -*-
require 'spec_helper'

describe '/balance' do
  context 'normally' do
    let(:valid_json) do
      {
        'accounts' =>
        [
         {
           'totals'  =>
           [
            {
              'amount'    => 0.25,
              'commodity' => 'BTC'
            }, {
              'amount'    => 3022.97,
              'commodity' => 'EUR'
            }
           ],
           'name'     => 'Assets',
           'depth'    => 1,
           'fullname' => 'Assets',
           'accounts' =>
           [
            {
              'totals' =>
              [
               {
                 'amount'    => 0.25,
                 'commodity' => 'BTC'
               }
              ],
              'name'     => 'Bitcoin',
              'depth'    => 2,
              'fullname' => 'Assets:Bitcoin'
            }, {
              'totals' =>
              [
               {
                 'amount'    => 5.7,
                 'commodity' => 'EUR'
               }
              ],
              'name'     => 'Cash',
              'depth'    => 2,
              'fullname' => 'Assets:Cash'
            }, {
              'totals'  =>
              [
               {
                 'amount'    => 2995.17,
                 'commodity' => 'EUR'
               }
              ],
              'name'     => 'Giro',
              'depth'    => 2,
              'fullname' => 'Assets:Giro'
            }, {
              'totals'  =>
              [
               {
                 'amount'    => 22.1,
                 'commodity' => 'EUR'
               }
              ],
              'name'     => 'Reimbursements',
              'depth'    => 2,
              'fullname' => 'Assets:Reimbursements',
              'accounts' =>
              [
               {
                 'totals'  =>
                 [
                  {
                    'amount'    => 22.1,
                    'commodity' => 'EUR'
                  }
                 ],
                 'name'     => 'Hans Maulwurf',
                 'depth'    => 3,
                 'fullname' => 'Assets:Reimbursements:Hans Maulwurf'
               }
              ]
            }
           ]
         },
         {
           'totals'  =>
           [
            {
              'amount'    => -12.0,
              'commodity' => 'EUR'
            }
           ],
           'name'     => 'Liabilities',
           'depth'    => 1,
           'fullname' => 'Liabilities',
           'accounts' =>
           [
            {
              'totals'  =>
              [
               {
                 'amount'    => -12.0,
                 'commodity' => 'EUR'
               }
              ],
              'name'     => 'Max Mustermann',
              'depth'    => 2,
              'fullname' => 'Liabilities:Max Mustermann'
            }
           ]
         }
        ],
        'totals' =>
        [
         {
           'amount'    => 0.25,
           'commodity' => 'BTC'
         }, {
           'amount'    => 3010.97,
           'commodity' => 'EUR'
         }
        ]
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
           'totals' =>
           [
            {
              'amount'    => 0.25,
              'commodity' => 'BTC'
            }
           ],
           'name'     => 'Bitcoin',
           'depth'    => 2,
           'fullname' => 'Assets:Bitcoin'
         }, {
           'totals' =>
           [
            {
              'amount'    => 5.7,
              'commodity' => 'EUR'
            }
           ],
           'name'     => 'Cash',
           'depth'    => 2,
           'fullname' => 'Assets:Cash'
         }, {
           'totals'  =>
           [
            {
              'amount'    => 2995.17,
              'commodity' => 'EUR'
            }
           ],
           'name'     => 'Giro',
           'depth'    => 2,
           'fullname' => 'Assets:Giro'
         }, {
           'totals'  =>
           [
            {
              'amount'    => 22.1,
              'commodity' => 'EUR'
            }
           ],
           'name'     => 'Reimbursements',
           'depth'    => 2,
           'fullname' => 'Assets:Reimbursements'
         }, {
           'totals'  =>
           [
            {
              'amount'    => 22.1,
              'commodity' => 'EUR'
            }
           ],
           'name'     => 'Hans Maulwurf',
           'depth'    => 3,
           'fullname' => 'Assets:Reimbursements:Hans Maulwurf'
         }, {
           'totals'  =>
           [
            {
              'amount'    => -12.0,
              'commodity' => 'EUR'
            }
           ],
           'name'     => 'Liabilities',
           'depth'    => 1,
           'fullname' => 'Liabilities'
         }, {
           'totals'  =>
           [
            {
              'amount'    => -12.0,
              'commodity' => 'EUR'
            }
           ],
           'name'     => 'Max Mustermann',
           'depth'    => 2,
           'fullname' => 'Liabilities:Max Mustermann' }
        ],
        'totals' =>
        [
         {
           'amount'    => 0.25,
           'commodity' => 'BTC'
         }, {
           'amount'    => 3010.97,
           'commodity' => 'EUR'
         }
        ]
      }
    end

    it 'does not wrap accounts' do
      get '/balance', query: '--flat Assets Liabilities'
      JSON.parse(last_response.body).should deep_eq valid_json
    end
  end
end
