#!/usr/bin/ruby

# Example code from Github API documentation on generating a JWT token

require 'openssl'
require 'jwt'  # https://rubygems.org/gems/jwt

# Variables to update
path = '/path/to/github-app.private-key.pem'
github_app_id = 1

# Private key contents
private_pem = File.read(path)
private_key = OpenSSL::PKey::RSA.new(private_pem)

# Generate the JWT
payload = {
  # issued at time
  iat: Time.now.to_i,
  # JWT expiration time (10 minute maximum)
  exp: Time.now.to_i + (10 * 60),
  # GitHub App's identifier
  iss: github_app_id
}

jwt = JWT.encode(payload, private_key, "RS256")
puts jwt
