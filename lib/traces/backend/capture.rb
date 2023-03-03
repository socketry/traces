# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative '../context'

require 'fiber'

class Fiber
	attr_accessor :traces_backend_context
end

module Traces
	module Backend
		# A backend which logs all spans to the Capture logger output.
		module Capture
			# A span which validates tag assignment.
			class Span
				def initialize(context, instance, name, resource, attributes)
					@context = context
					@instance = instance
					@name = name
					@resource = resource
					@attributes = attributes
				end
				
				attr :context
				attr :instance
				attr :name
				attr :resource
				attr :attributes
				
				# Assign some metadata to the span.
				# @parameter key [String] The metadata key.
				# @parameter value [Object] The metadata value. Should be coercable to a string.
				def []= key, value
					@attributes[key] = value
				end
				
				def as_json
					{
						name: @name,
						resource: @resource,
						attributes: @attributes,
						context: @context.as_json
					}
				end
				
				def to_json(...)
					as_json.to_json(...)
				end
			end
			
			def self.spans
				@spans ||= []
			end
			
			module Interface
				# Trace the given block of code and log the execution.
				# @parameter name [String] A useful name/annotation for the recorded span.
				# @parameter attributes [Hash] Metadata for the recorded span.
				def trace(name, resource: self, attributes: {}, &block)
					context = Context.nested(Fiber.current.traces_backend_context)
					Fiber.current.traces_backend_context = context
					
					span = Span.new(context, self, name, resource, attributes)
					Capture.spans << span
					
					yield span
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
		
		Interface = Capture::Interface
	end
end
