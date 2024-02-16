require_relative '../../app/controllers/users_controller'
require_relative '../spec_helper'

RSpec.describe 'Sinatra Application' do
  include Rack::Test::Methods

  def app
    UsersController
  end

  describe 'POST /register' do
    it 'redirects to login' do
      post '/register', { email: Faker::Internet.email, password: 'Pa@123' }
      expect(User.count).to eq(1)
    end

    it 'unable to create user without valid password' do
      post '/register', { email: Faker::Internet.email, password: 'password' }
      expect(User.count).to eq(0)
    end
  end


  describe 'POST /login' do
    let(:user) { User.create(email: Faker::Internet.email, password_digest: BCrypt::Password.create('Pa@123'), two_factor_enabled: false) }
    let(:user_1) { User.create(email: Faker::Internet.email, password_digest: BCrypt::Password.create('Pa@123'), two_factor_enabled: true) }

    context 'with valid credentials and two-factor disabled' do
      it 'redirects to account settings page' do
        post '/login', { email: user.email, password_digest: 'Pa@123' }
        expect(last_response.redirect?).to be true
        expect(URI.parse(last_response.location).path).to eq("/account/settings")
      end
    end

    context 'with valid credentials and two-factor enable' do
      it 'redirects to account settings page' do
        post '/login', { email: user_1.email, password_digest: 'Pa@123' }
        expect(last_response.redirect?).to be true
        expect(URI.parse(last_response.location).path).to eq("/setup-2fa")
      end
    end
  end

  describe 'POST /logout' do
    it 'clears the session' do
      post '/logout'
      expect(last_response).to be_redirect
      expect(URI.parse(last_response.location).path).to eq("/login")
    end
  end

  describe 'POST /account/password/update' do
    context 'when user is logged in and provides correct current password' do
      let(:user) { User.create(email: Faker::Internet.email, password_digest: BCrypt::Password.create('Pa@123'), two_factor_enabled: false) }
      before do
        post '/login', { email: user.email, password_digest: 'Pa@123' }
      end

      it 'updates the password and redirects to account settings page with success message' do
        post '/account/password/update', { current_password: 'Pa@123', new_password: 'Aa@123' }

        expect(last_response.redirect?).to be true
        expect(last_response.location).to include('/account/settings?password_updated=true')
      end
    end

    context 'when user is logged in but provides incorrect current password' do
      let(:user) { User.create(email: Faker::Internet.email, password_digest: BCrypt::Password.create('Pa@123'), two_factor_enabled: false) }
      before do
        post '/login', { email: user.email, password_digest: 'Pa@123' }
      end

      it 'redirects to account settings page with error message' do
        post '/account/password/update', { current_password: 'Ba@123', new_password: 'Aa@123' }

        expect(last_response.redirect?).to be true
        expect(last_response.location).to include('/account/settings?error=invalid_password')
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login page' do
        post '/account/password/update', { current_password: 'Pa@123', new_password: 'Aa@123' }

        expect(last_response.redirect?).to be true
        expect(last_response.location).to include('/login')
      end
    end
  end

  describe 'POST /account/2fa' do
    context 'when user is logged in' do
      let(:user) { User.create(email: Faker::Internet.email, password_digest: BCrypt::Password.create('Pa@123'), two_factor_enabled: true) }
      before do
        allow_any_instance_of(UsersController).to receive(:current_user).and_return(user)
        allow_any_instance_of(UsersController).to receive(:session).and_return({"user_id"=>user.id})
      end

      context 'when enabling 2FA' do
        it 'redirects to setup-2fa page with 2FA enabled' do
          post '/account/2fa', { enable_2fa: 'true' }

          expect(last_response.redirect?).to be true
          expect(last_response.location).to include('/setup-2fa?2fa_enabled=true')
        end
      end

      context 'when disabling 2FA' do
        let(:user) { User.create(email: Faker::Internet.email, password_digest: BCrypt::Password.create('Pa@123'), two_factor_enabled: false) }
        before do
          post '/login', { email: user.email, password_digest: 'Pa@123' }
        end
        it 'redirects to setup-2fa page with 2FA disabled' do
          post '/account/2fa', { enable_2fa: 'false' }

          expect(last_response.redirect?).to be true
          expect(last_response.location).to include('/setup-2fa?2fa_enabled=false')
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login page' do
        post '/account/2fa', { enable_2fa: 'true' }

        expect(last_response.redirect?).to be true
        expect(last_response.location).to include('/login')
      end
    end
  end

  describe 'POST /verify-2fa' do
    let(:user) { User.create(email: Faker::Internet.email, password_digest: BCrypt::Password.create('Pa@123'), two_factor_enabled: true) }
    context 'when verifying 2FA' do
      it 'redirects to account settings page if token is valid' do
        allow_any_instance_of(UsersController).to receive(:current_user).and_return(user)
        allow_any_instance_of(UsersController).to receive(:session).and_return({"user_id"=>user.id})
        allow_any_instance_of(UsersController).to receive(:verify_token).and_return(true)

        post '/verify-2fa', { user_id: user.id, token: 'fake_token', fa: 'true' }

        expect(last_response.redirect?).to be true
        expect(last_response.location).to include('/account/settings')
      end

      it 'redirects to login page with error message if token is invalid' do
        allow_any_instance_of(UsersController).to receive(:current_user).and_return(user)
        allow_any_instance_of(UsersController).to receive(:session).and_return({"user_id"=>user.id})
        allow_any_instance_of(UsersController).to receive(:verify_token).and_return(false)

        post '/verify-2fa', { user_id: user.id, token: 'invalid_token', fa: 'true' }

        expect(last_response.redirect?).to be true
        expect(last_response.location).to include('/login?error=invalid_code')
      end
    end
  end
end
