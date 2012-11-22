# -*- coding: utf-8 -*-
require 'rubygems'
require 'fileutils'
require 'json'
require 'yaml'
require 'bundler'

Bundler.require

require 'ledger-rest/app'

module LedgerRest
  VERSION = "2.0"
end
