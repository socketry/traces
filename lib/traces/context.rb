# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require 'securerandom'

module Traces
	# A generic representation of the current tracing context.
	class Context
		# Parse a string representation of a distributed trace.
		# @parameter parent [String] The parent trace context.
		# @parameter state [Array(String)] Any attached trace state.
		def self.parse(parent, state = nil, **options)
			version, trace_id, parent_id, flags = parent.split('-')
			
			if version == '00'
				flags = Integer(flags, 16)
				
				if state.is_a?(String)
					state = state.split(',')
				end
				
				if state
					state = state.map{|item| item.split('=')}.to_h
				end
				
				self.new(trace_id, parent_id, flags, state, **options)
			end
		end
		
		# Create a local trace context which is likley to be globally unique.
		# @parameter flags [Integer] Any trace context flags.
		def self.local(flags = 0, **options)
			self.new(SecureRandom.hex(16), SecureRandom.hex(8), flags, **options)
		end
		
		# Nest a local trace context in an optional parent context.
		# @parameter parent [Context] An optional parent context.
		def self.nested(parent, flags = 0)
			if parent
				parent.nested(flags)
			else
				self.local(flags)
			end
		end
		
		SAMPLED = 0x01
		
		def initialize(trace_id, parent_id, flags, state = nil, remote: false)
			@trace_id = trace_id
			@parent_id = parent_id
			@flags = flags
			@state = state
			@remote = remote
		end
		
		# Create a new nested trace context in which spans can be recorded.
		def nested(flags = @flags)
			Context.new(@trace_id, SecureRandom.hex(8), flags, @state, remote: @remote)
		end
		
		# The ID of the whole trace forest and is used to uniquely identify a distributed trace through a system. It is represented as a 16-byte array, for example, 4bf92f3577b34da6a3ce929d0e0e4736. All bytes as zero (00000000000000000000000000000000) is considered an invalid value.
		attr :trace_id
		
		# The ID of this request as known by the caller (in some tracing systems, this is known as the span-id, where a span is the execution of a client request). It is represented as an 8-byte array, for example, 00f067aa0ba902b7. All bytes as zero (0000000000000000) is considered an invalid value.
		attr :parent_id
		
		# An 8-bit field that controls tracing flags such as sampling, trace level, etc. These flags are recommendations given by the caller rather than strict rules.
		attr :flags
		
		# Provides additional vendor-specific trace identification information across different distributed tracing systems. Conveys information about the request’s position in multiple distributed tracing graphs.
		attr :state
		
		# Denotes that the caller may have recorded trace data. When unset, the caller did not record trace data out-of-band.
		def sampled?
			(@flags & SAMPLED) != 0
		end
		
		# Whether this context was created from a distributed trace header.
		def remote?
			@remote
		end
		
		# A string representation of the trace context (excluding trace state).
		def to_s
			"00-#{@trace_id}-#{@parent_id}-#{@flags.to_s(16)}"
		end
	end
end
