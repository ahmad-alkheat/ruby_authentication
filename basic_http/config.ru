#simple HTTP authentication using RACK::Auth::Basic
class Application
	def call(env)
		[200, {}, ['Hi, you are authenticated'] ]
	end
end

use Rack::Auth::Basic do | username, password |
	username == 'Ahmad' && password == '123456789'
end

run Application.new