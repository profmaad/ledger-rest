# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require './version'

Gem::Specification.new do |gem|
  gem.name          = "ledger-rest"
  gem.version       = LedgerRest::VERSION
  gem.authors       = ["Prof. MAAD", "Arthur Andersen"]
  gem.email         = ["leoc.git@gmail.com"]
  gem.description   = %q{Provide a REST web service for ledger.}
  gem.summary       = %q{Ledger via REST.}
  gem.homepage      = "https://github.com/leoc/ledger-rest"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
