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
    db_config = YAML.load_file('config/database.yml')['development']
    Sequel::Migrator.run(Sequel.connect(db_config), 'db/migrations')
    puts "Migrations executed successfully on development database."
  end

  desc 'Run database migrations for test environment'
  task :migrate_test do
    db_config = YAML.load_file('config/database.yml')['test']
    Sequel::Migrator.run(Sequel.connect(db_config), 'db/migrations')
    puts "Migrations executed successfully on test database."
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
      puts "Development database #{database_name} created successfully."
    end
  end

  desc "Create the test database"
  task :create_test do
    db_config = YAML.load_file('config/database.yml')['test']
    database_name = db_config['database']
    db_config['database'] = 'postgres'  # Set database to 'postgres' temporarily for creating the new database

    Sequel.connect(db_config) do |db|
      db.execute("CREATE DATABASE #{database_name}")
      puts "Test database #{database_name} created successfully."
    end
  end
end

task "server" do
  exec 'ruby app/controllers/users_controller.rb'
end

namespace :console do
  desc 'Starts a console with access to your application environment'
  task :start do
    require './app/controllers/users_controller.rb'
    puts 'Loading application environment...'

    puts 'Starting console...'
    Pry.start(binding, quiet: true)
  end
end