require 'sequel'
require 'yaml'
Sequel.connect(YAML.load_file('config/database.yml')['development'])

class User < Sequel::Model
  
end

