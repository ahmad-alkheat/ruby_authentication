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
		DB[:users].insert(username: params[:username], encrypted_password: BCrypt::Password.create(params[:password]))
	end
end

class Login
	def call(env)
		request = Rack::Request.new(env)
		if request.post?
			user = DB[:users][username: request.params['username']]
			if user && BCrypt::Password.new(user[:encrypted_password] == request.params['password'])
				env['rack_session']['user_id'] = user[:id]
				[ 301, { 'Location' => '/'}, [ ] ]
			else
				[ 301, { 'Location' => '/login'}, [] ]
			end
		else
			[ 200, { 'Content-Type' => 'text/html'}, [ File.read('login.html')]]
		end
	end
end



class Signup
	def call(env)
		req = Rack::Request.new(env)

		if req.post?
			User.register(req.params)
			[ 301, { 'Location' => '/login' }, [] ]
		else
			[ 200, { 'Content-Type' => 'text/html' }, [ File.read('signup.html')]]
		end
	end
end

map '/signup' do
	run Signup.new
end

map '/login' do
	run Login.new
end

run Application.new