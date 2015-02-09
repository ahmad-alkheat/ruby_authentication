require 'json'
require 'sequel'
require 'bcrypt'

use Rack::Session::Cookie, secret: "onaunfntoyfunt"


class Application
  def call(env)
    if authenticated?(env['HTTP_TOKEN'])
      body = 'authenticated'
    else
      body = 'not authenticated'
    end
     [ 200, { 'Content_type' => 'application/json' }, [ { content: body }.to_json] ]
  end

  def authenticated?(token)
    token && DB[:users][authentication_token: token]
  end
end

class Login
  def call(env)
    req = Rack::Request.new(env)

    user = DB[:users][username: req.params['username']]

    if user && BCrypt::Password.new(user[:encrypted_password]) == req.params['password']
      token = SecureRandom.urlsafe_base64(15)
      DB[:users].where(username: req.params['username']).update(authentication_token: token)
      [ 301, { 'Content_type' => 'application/json' }, [ { auth_token: token }.to_json ] ]
    else
      [ 401, {}, [] ]
    end
  end
end

DB = Sequel.sqlite

DB.create_table :users do 
  String :username
  String :encrypted_password
  String :authentication_token
end

pass = BCrypt::Password.create('pass')
DB[:users].insert( username: 'test', encrypted_password: pass)

map '/login' do
  run Login.new
end

 run Application.new
