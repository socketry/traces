# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

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
		Traces.trace("my_trace", attributes: {foo: "bar"}) do |span|
			span[:foo] = "baz"
			super
		end
	end
	
	def nested
		Traces.trace("nested") do
			context = Traces.trace_context
			
			super do
				Traces.trace_context = context
				
				yield
			end
		end
	end
end
