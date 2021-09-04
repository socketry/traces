# config/initializers/datadog-tracer.rb

require 'ddtrace'

Datadog.configure do |c|
	c.tracer.enabled = false
	
	# To enable debug mode
	c.diagnostics.debug = true
end