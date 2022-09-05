# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

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
				def trace_context
					Fiber.current.traces_backend_context
				end
			end
		end
		
		Interface = Console::Interface
	end
end
