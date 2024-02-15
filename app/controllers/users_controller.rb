require 'sinatra'
require 'bcrypt'
require 'pony'
require_relative '../models/user'

# Enable sessions and set views directory
enable :sessions
set :views, File.expand_path('../views', __dir__)

helpers do
  # Method to retrieve the current user based on session
  def current_user
    User.first(id: session[:user_id])
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
get '/register' do
  redirect "/account/settings?session_id=true" if current_user
  erb :register, locals: { errors: [] }
end

# Route for processing registration form submission
post '/register' do
  email = params['email']
  password = params['password_digest']
  user = User.new(email: email, password_digest: BCrypt::Password.create(password))

  if user.save
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
      redirect("/account/settings")
    end
  else
    redirect '/login?error=invalid_credentials'
  end
end

# Route for logging out
post '/logout' do
  session.clear if current_user
  redirect '/login?error=logout'
end
