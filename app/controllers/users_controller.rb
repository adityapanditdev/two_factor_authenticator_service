require 'sinatra'
require 'bcrypt'
require 'pony'
require 'rotp'
require 'rqrcode'
require 'base64'
require 'byebug'
require 'sinatra/base'

require_relative '../models/user'

class UsersController < Sinatra::Base
  # Enable sessions and set views directory
  enable :sessions
  set :views, File.expand_path('../views', __dir__)

  helpers do
    # Method to retrieve the current user based on session
    def current_user
      User.first(id: session[:user_id])
    end

    # Method to require user login
    def require_login
      redirect '/login?error=session_expired' if current_user.nil?
    end

    # Method to generate a secret key for 2FA
    def generate_secret
      current_user.update(token: ROTP::Base32.random_base32) if current_user.token.nil?
    end

    # Method to generate a QR code URL for the secret key
    def generate_qr_code_url(secret, username)
      issuer = 'two_factor_authentication' # Customize issuer if needed
      ROTP::TOTP.new(secret, issuer: issuer).provisioning_uri(username)
    end

    # Method to verify the token entered by the user
    def verify_token(secret, token)
      totp = ROTP::TOTP.new(secret)
      totp.verify(token)
    end

    # Method to send confirmation email
    def send_confirmation_email(email)
      Pony.mail({
        to: email,
        subject: 'Registration Confirmation',
        body: 'Thank you for registering!',
        via: :smtp,
        via_options: {
          address: 'smtp.gmail.com',
          port: '587',
          user_name: 'rordev123456@gmail.com',
          password: 'ktmdrloqmibaxknl',
          authentication: :plain,
          domain: 'gmail.com'
        }
      })
    end
  end

  # Route for displaying registration form
  get '/' do
    redirect "/account/settings?session_id=true" if current_user
    erb :register, locals: { errors: [] }
  end

  # Route for processing registration form submission
  post '/register' do
    email = params['email']
    password = params['password']
    user = User.new(email: email, password_digest: password)
    
  if user.valid?
      encrypted_password = BCrypt::Password.create(password)
      user.password_digest = encrypted_password
      user.save
      send_confirmation_email(email)
      redirect '/login'
    else    
      erb :register, locals: { errors: user.errors.full_messages }
    end
  end


  # Route for displaying login form
  get '/login' do
    redirect "/account/settings" if current_user
    erb :login, locals: { error: params['error'].to_s }
  end

  # Route for processing login form submission
  post '/login' do
    email = params['email']
    password = params['password_digest']
    user = User.authenticate(email, password)

    if user && BCrypt::Password.new(user.password_digest) == password
      if user.two_factor_enabled
        redirect("/setup-2fa?user_id=#{user.id}")
      else
        session[:user_id] = user.id
        redirect "/account/settings"
      end
    else
      redirect '/login?error=invalid_credentials'
    end
  end

  # Route for logging out
  post '/logout' do
    session[:user_id] = nil if current_user
    redirect '/login?error=logout'
  end

  # Route for displaying account settings
  get '/account/settings' do
    require_login
    erb :account_settings, locals: { user: current_user }
  end

  # Route for updating password
  post '/account/password/update' do
    require_login
    current_password = params['current_password']
    new_password = params['new_password']

    if BCrypt::Password.new(current_user.password_digest) == current_password
      current_user.update(password_digest: BCrypt::Password.create(new_password))
      redirect "/account/settings?password_updated=true"
    else
      redirect "/account/settings?error=invalid_password"
    end
  end

  # Route for enabling/disabling 2FA
  post '/account/2fa' do
    require_login
    enable_2fa = params['enable_2fa'] == 'true'

    if enable_2fa
      generate_secret
      redirect '/setup-2fa?2fa_enabled=true'
    else
      redirect "/setup-2fa?2fa_enabled=false"
    end
    redirect "/account/settings?2fa_enabled=true"
  end

  # Route for displaying setup 2FA page
  get '/setup-2fa' do
    user = User.first(id: params[:user_id]) if current_user == nil
    @username = current_user ? current_user.email : user.email
    @secret = current_user ? current_user.token : user.token
    qr_code_url = generate_qr_code_url(@secret, @username)
    qr = RQRCode::QRCode.new(qr_code_url)
    svg = qr.as_svg(module_size: 3)
    @encoded_svg = Base64.strict_encode64(svg)
    erb :setup_2fa
  end

  # Route for verifying 2FA token
  post '/verify-2fa' do
    user = User.first(id: params[:user_id]) if current_user == nil
    secret = current_user ? current_user.token : user.token
    token = params[:token]
    if params[:fa] == 'true'
      current_user.update(two_factor_enabled: true)
    elsif params[:fa] == 'false'
      current_user.update(two_factor_enabled: false)
    end

    if verify_token(secret, token)
      session[:user_id] = current_user ? current_user.id : user.id
      redirect "/account/settings"
    else
      session.clear
      redirect "/login?error=invalid_code"
    end
  end
  run! if app_file == $0
end
