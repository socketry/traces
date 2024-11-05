# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

require_relative 'config'

module Traces
	# The backend implementation is responsible for recording and reporting traces.
	module Backend
	end
	
	Config::DEFAULT.require_backend
end
