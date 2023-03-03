
def environment
	require_relative 'app'
end

def run
	self.environment
	
	# Fake tests that emit metrics:
	app = App.new
	app.call
end
