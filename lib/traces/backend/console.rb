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

require 'console'
require 'fiber'

class Fiber
	attr_accessor :traces_backend_context
end

module Traces
	module Backend
		# A backend which logs all spans to the console logger output.
		module Console
			# A span which validates tag assignment.
			class Span
				def initialize(context, instance, name)
					@context = context
					@instance = instance
					@name = name
				end
				
				attr :context
				
				# Assign some metadata to the span.
				# @parameter key [String] The metadata key.
				# @parameter value [Object] The metadata value. Should be coercable to a string.
				def []= key, value
					::Console.logger.info(@context, @name, "#{key} = #{value}")
				end
			end
			
			module Interface
				# Trace the given block of code and log the execution.
				# @parameter name [String] A useful name/annotation for the recorded span.
				# @parameter attributes [Hash] Metadata for the recorded span.
				def trace(name, resource: self, attributes: {}, &block)
					context = Context.nested(Fiber.current.traces_backend_context)
					Fiber.current.traces_backend_context = context
					
					::Console.logger.info(resource, name, attributes)
					
					if block.arity.zero?
						yield
					else
						yield Span.new(context, self, name)
					end
				end
				
				# Assign a trace context to the current execution scope.
				def trace_context= context
					Fiber.current.traces_backend_context = context
				end
				
				# Get a trace context from the current execution scope.
				# @parameter span [Span] An optional span from which to extract the context.
				def trace_context(span = nil)
					if span
						span.context
					else
						Fiber.current.traces_backend_context
					end
				end
			end
		end
		
		Interface = Console::Interface
	end
end
