# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

require 'console/event/failure'

module Traces
	module Backend
		# Require a specific trace backend.
		def self.require_backend(env = ENV)
			if backend = env['TRACES_BACKEND']
				begin
					require(backend)
				rescue LoadError => error
					::Console::Event::Failure.for(error).emit(self, "Unable to load traces backend!", backend: backend, severity: :warn)
					
					return false
				end
				
				Traces.extend(Backend::Interface)
				
				return true
			end
		end
	end
end

Traces::Backend.require_backend
