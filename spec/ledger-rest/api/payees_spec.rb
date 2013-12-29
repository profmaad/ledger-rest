# -*- coding: utf-8 -*-
require 'spec_helper'

describe '/payees' do
  it 'returns payees' do
    get '/payees'

    JSON.parse(last_response.body).should =~
      [
       'Bioladen Tegeler Straße',
       'Customer X',
       'My Very Sane Bitcoin Exchange',
       'NaveenaPath',
       'Opening Balance',
       'Shikgoo',
       'Sparkasse',
       'Trattoria La Vialla'
      ]
  end
end
