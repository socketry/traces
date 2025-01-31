# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

require_relative 'config'

module Traces
	# The backend implementation is responsible for recording and reporting traces.
	module Backend
	end
	
	# This is a default implementation, which can be replaced by the backend.
	# @returns [Boolean] Whether there is an active trace.
	def self.active?
		!!self.trace_context
	end
	
	Config::DEFAULT.require_backend
end
