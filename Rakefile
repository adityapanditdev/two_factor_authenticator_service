# Rakefile

require 'sequel'
require 'sequel/extensions/migration'
require 'yaml'
require 'pry'

Sequel.extension :migration

# Configure your database connection

namespace :db do
  desc 'Run database migrations'
  task :migrate do
    Sequel::Migrator.run(Sequel.connect(YAML.load_file('config/database.yml')['development']), 'db/migrations')
    puts "created successfully"
  end
end


namespace :db do
  desc "Create the database"
  task :create do
    db_config = YAML.load_file('config/database.yml')['development']
    database_name = db_config['database']
    db_config['database'] = 'postgres'  # Set database to 'postgres' temporarily for creating the new database

    Sequel.connect(db_config) do |db|
      db.execute("CREATE DATABASE #{database_name}")
      puts "Database #{database_name} created successfully."
    end
  end
end