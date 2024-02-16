require_relative '../spec_helper'
require_relative '../../app/models/user'

RSpec.describe User do
  describe 'validations' do
    it 'validates presence of email' do
      user = User.new(email: nil, password_digest: 'password123')
      expect(user.valid?).to be false
      expect(user.errors[:email]).to include('is not present')
    end

    it 'validates format of email' do
      user = User.new(email: 'invalid_email', password_digest: 'password123')
      expect(user.valid?).to be false
      expect(user.errors[:email]).to include('is not a valid email address')
    end

    it 'validates uniqueness of email' do
      User.create(email: 'test@example.com', password_digest: 'Pa@123')
      user = User.new(email: 'test@example.com', password_digest: 'Pa@123')
      expect(user.valid?).to be false
      expect(user.errors[:email]).to include('is already taken')
    end

    it 'validates password complexity' do
      user = User.new(email: 'test@example.com', password_digest: 'password')
      expect(user.valid?).to be false
      expect(user.errors[:password_digest]).to include('must contain at least one uppercase letter, one lowercase letter, one digit, and one special character')
    end
  end

  describe '.authenticate' do
    it 'returns user if email and password match' do
      user = User.create(email: 'test@example.com', password_digest: BCrypt::Password.create('Pa@123'))
      authenticated_user = User.authenticate('test@example.com', 'Pa@123')
      expect(authenticated_user).to eq(user)
    end

    it 'returns nil if email does not exist' do
      authenticated_user = User.authenticate('nonexistent@example.com', 'password')
      expect(authenticated_user).to be_nil
    end

    it 'returns nil if password is incorrect' do
      user = User.create(email: 'test@example.com', password_digest: BCrypt::Password.create('Pa@123'))
      authenticated_user = User.authenticate('test@example.com', 'incorrect_password')
      expect(authenticated_user).to be_nil
    end
  end
end
