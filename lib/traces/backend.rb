# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

module Traces
	# Require a specific trace backend.
	def self.require_backend(env = ENV)
		if backend = env['TRACES_BACKEND']
			require(backend)
		end
	end
end

Traces.require_backend
