# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ledger-rest/version'

Gem::Specification.new do |gem|
  gem.name          = 'ledger-rest'
  gem.version       = LedgerRest::VERSION
  gem.authors       = ['Prof. MAAD', 'Arthur Andersen']
  gem.email         = ['leoc.git@gmail.com']
  gem.description   = %q{Provide a REST web service for ledger.}
  gem.summary       = %q{Ledger via REST.}
  gem.homepage      = 'https://github.com/leoc/ledger-rest'

  gem.files         = `git ls-files`.split($RS)
  gem.executables   = gem.files.grep(/^bin\//).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(/^(test|spec|features)\//)
  gem.require_paths = ['lib']

  gem.add_dependency 'escape'
  gem.add_dependency 'sinatra'
  gem.add_dependency 'git'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'rb-inotify'
  gem.add_development_dependency 'guard-rspec'
end
