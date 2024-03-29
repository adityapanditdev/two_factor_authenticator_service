require 'sequel'
require 'yaml'
require 'byebug'
require 'bcrypt'

# Set RACK_ENV to 'development' if it's not defined
ENV['RACK_ENV'] ||= 'development'

# Establish database connection based on environment
DB_CONFIG = YAML.load_file('config/database.yml')
DB = Sequel.connect(ENV['RACK_ENV'] == 'test' ? DB_CONFIG['test'] : DB_CONFIG['development'])

class User < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence :email
    validates_format(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, :email, message: 'is not a valid email address')
    validates_unique :email
    validates_password_complexity :password_digest
  end

  def self.authenticate(email, password)
    user = User.first(email: email)
    return nil unless user
    if BCrypt::Password.new(user.password_digest) == password
      return user
    else
      return nil
    end
  end

  private

  def validates_password_complexity(attribute)
    value = send(attribute)

    unless /^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{6,}$/.match?(value)
      errors.add(attribute, "must contain at least one uppercase letter, one lowercase letter, one digit, and one special character")
    end
  end
end


