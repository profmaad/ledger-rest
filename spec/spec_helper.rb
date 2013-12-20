ENV['CONFIG_FILE'] ||= 'spec/ledger-rest.yml'

require 'ledger-rest'
require 'rack/test'

require 'support/deep_eq_matcher.rb'

module RSpecMixin
  include Rack::Test::Methods
  def app
    LedgerRest::App
  end
end

RSpec.configure do |config|
  config.include RSpecMixin

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'
end

def restore_file(filename)
  FileUtils.cp(filename, "#{filename}.backup")
  yield
ensure
  FileUtils.rm(filename)
  FileUtils.mv("#{filename}.backup", filename, force: true)
end
