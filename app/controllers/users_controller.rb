require 'sinatra'
require 'bcrypt'
require 'pony'
require 'byebug'
require_relative '../models/user'

set :views, File.expand_path('../views', __dir__)

# Route for displaying registration form
get '/register' do
  erb :register, locals: { errors: [] }
end

# Route for processing registration form submission
post '/register' do
  # Retrieve form data
  byebug
  email = params['email']
  password = params['password_digest']

  # Create a new user instance with the provided data
  user = User.new(email: email, password_digest: password)

  # Validate the user data
  if user.valid?
    # Hash and securely store the password using bcrypt
    hashed_password = BCrypt::Password.create(password)

    # Update the user's password digest with the hashed password
    user.password_digest = hashed_password

    # Save the user to the database
    user.save

    # Send confirmation email
    send_confirmation_email(email)

    # Redirect to a confirmation page or login page
    redirect '/confirmation'
  else
    # If there are validation errors, render the registration form with error messages
    erb :register, locals: { errors: user.errors.full_messages }
  end
end

# Method to send confirmation email
def send_confirmation_email(email)
  # Replace the placeholders with your actual email configuration
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
