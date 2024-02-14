require 'sequel'
require 'yaml'
require 'byebug'
Sequel.connect(YAML.load_file('config/database.yml')['development'])

class User < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence :email
    validates_format(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, :email, message: 'is not a valid email address')
    validates_unique :email
    validates_password_complexity :password_digest
  end

  private

  def validates_password_complexity(attribute)
    byebug
    value = send(attribute)

    unless /^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{6,}$/.match?(value)
      errors.add(attribute, "must contain at least one uppercase letter, one lowercase letter, one digit, and one special character")
    end
  end
end


