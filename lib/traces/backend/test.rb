# frozen_string_literal: true

# Copyright, 2021, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative '../context'
require 'fiber'

class Fiber
	attr_accessor :traces_backend_context
end

module Traces
	module Backend
		# A backend which validates interface usage.
		module Test
			# A span which validates tag assignment.
			class Span
				def initialize(context)
					@context = context
				end
				
				attr :context
				
				# Assign some metadata to the span.
				# @parameter key [String] The metadata key.
				# @parameter value [Object] The metadata value. Should be coercable to a string.
				def []= key, value
					unless key.is_a?(String)
						raise ArgumentError, "Invalid name (must be String): #{key.inspect}!"
					end
					
					unless String(value)
						raise ArgumentError, "Invalid value (must be String): #{value.inspect}!"
					end
				end
			end
			
			module Interface
				# Trace the given block of code and validate the interface usage.
				# @parameter name [String] A useful name/annotation for the recorded span.
				# @parameter attributes [Hash] Metadata for the recorded span.
				def trace(name, resource: self.class.name, attributes: nil, &block)
					unless name.is_a?(String)
						raise ArgumentError, "Invalid name (must be String): #{name.inspect}!"
					end
					
					if resource
						# It should be convertable:
						resource = resource.to_s
					end
					
					context = Context.nested(Fiber.current.traces_backend_context)
					Fiber.current.traces_backend_context = context
					
					if block.arity.zero?
						yield
					else
						span = Span.new(context)
						yield span
					end
				end
				
				# Assign a trace context to the current execution scope.
				def trace_context= context
					Fiber.current.traces_backend_context = context
				end
				
				# Get a trace context from the current execution scope.
				def trace_context
					Fiber.current.traces_backend_context
				end
			end
		end
		
		Interface = Test::Interface
	end
end
