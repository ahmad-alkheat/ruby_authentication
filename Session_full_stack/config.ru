require 'sequel'
require 'bcrypt'

class Application 
	def call(env)
		[ 200, {}, [] ]
	end
end

DB = Sequel.sqlite

DB.create_table :users do
	primary_key :id
	String :username
	String :encrypted_password
end

class User
	def self.register(params)
		DB[:users].insert(username: params[:username], encrypted_password: Bcrypt::Password.create(params[:password]))
	end
end

class Signup
	def call(env)
		req = Rack::Request.new(env)

		if req.post?
			User.register(eq.params)
			[ 301, { 'Location' => '/login' }, [] ]
		else
			[ 200, { 'Content-Type' => 'text/html' }, [ File.read('signup.html')]]
		end
	end
end

map '/signup' do
	run Signup.new
end

run Application.new