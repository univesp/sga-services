require 'json'
require 'jwt'
require 'sinatra/base'
require 'httparty'
require 'dotenv/load'
require 'google/cloud/datastore'
require_relative 'jwt_auth'
require_relative 'lib/canvas/routes'

class Api < Sinatra::Base
  use JwtAuth
  include Canvas::Routes
end

class Public < Sinatra::Base
  def initialize
    super
    @logins = {
      sga: ENV['SGA_PASSWORD']
    }
  end

  post '/login' do
    username = params[:username]
    password = params[:password]
    if @logins[username.to_sym] == password
      content_type :json
      { token: token(username) }.to_json
    else
      halt 401
    end
  end

  def token(username)
    JWT.encode payload(username), ENV['JWT_SECRET'], 'HS256'
  end

  def payload(username)
    {
      exp: Time.now.to_i + 60 * 60,
      iat: Time.now.to_i,
      iss: ENV['JWT_ISSUER'],
      user: {
        username: username
      }
    }
  end
end