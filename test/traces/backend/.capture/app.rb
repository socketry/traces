
require 'traces/provider'

class App
	def call
		nested do
		end
	end
	
	def nested(&block)
		Thread.new(&block).join
	end
end

Traces::Provider(App) do
	def call
		trace("my_trace", resource: "my_resource", attributes: {foo: "bar"}) do |span|
			span[:foo] = "baz"
			super
		end
	end
	
	def nested
		trace("nested") do
			context = self.trace_context
			
			super do
				self.trace_context = context
				
				yield
			end
		end
	end
end
