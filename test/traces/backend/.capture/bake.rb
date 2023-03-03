# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

def environment
	require_relative 'app'
end

def run
	self.environment
	
	# Fake tests that emit metrics:
	app = App.new
	app.call
end
