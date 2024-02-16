# Two-Factor Authentication Service

## Description

The Two-Factor Authentication (2FA) Service is a web application built using the Sinatra framework in Ruby. It provides users with an added layer of security by implementing two-factor authentication. The application allows users to register, log in, and manage their account settings.

## Key Features

- **User Registration:** Users can register for an account by providing their email and password.
- **User Authentication:** Registered users can log in to their account using their email and password.
- **Two-Factor Authentication (2FA):** Users have the option to enable two-factor authentication for their account, adding an extra layer of security.
- **QR Code Integration:** Users are provided with a secret key (or QR code) to set up their authenticator app (e.g., Google Authenticator).
- **Account Settings:** Users can manage their account settings, including updating their password and enabling/disabling 2FA.

## Technologies Used

- **Ruby:** Programming language used for backend development.
- **Sinatra:** Lightweight web framework used for building web applications.
- **BCrypt:** Encryption library used for securely storing user passwords.
- **Pony:** Gem used for sending confirmation emails to users.
- **ROTP:** Library used for generating and verifying one-time codes for 2FA.
- **RQRCode:** Library used for generating QR codes.
- **RSpec:** Testing framework used for writing and executing tests.

## Getting Started

To run the application locally, follow these steps:

1. Clone this repository to your local machine.
2. Install Ruby 3.2.2 if you haven't already.
3. Install dependencies by running bundle install.
4. Set up the database by running 
```bash
  rake db:create
```
5. Set up the database by running 
```bash
  rake db:migrate
```
6. Start the server by running 
```bash
  rake server
```
7. Access the application in your web browser at http://localhost:4567.
8. For running console
```bash
  rake console:start
```

## Usage

1. Register for a new account using your email and password.
2. Log in to your account.
3. Enable two-factor authentication for added security.
4. Manage your account settings as needed.

## Testing

This project includes RSpec tests to ensure the application functions correctly. Run rspec in your terminal to execute the tests.

Setup the Test Environment, follow these steps:

1. Set up the database by running 
```bash
  rake db:create_test
```
2. Set up the database by running 
```bash
  rake db:migrate_test
```
3. Run the Specs
```bash
  RAKE_ENV=test rspec spec
```
3. Run the particular spec file
```bash
  RAKE_ENV=test rspec < ./relative_path_of_the_spec_file >
```
