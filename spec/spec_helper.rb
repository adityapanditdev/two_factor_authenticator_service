require 'sequel'
require 'yaml'
require 'byebug'
require 'rspec'
require 'faker'
require 'rack/test'

test_db = Sequel.connect(YAML.load_file('config/database.yml')['test'])
RSpec.configure do |config|
  config.before(:each) do
    # Delete data from the users table before each example
    test_db[:users].delete
  end
end