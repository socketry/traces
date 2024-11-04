# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

module Traces
	class Config
		DEFAULT_PATH = ENV.fetch("TRACES_CONFIG_DEFAULT_PATH", "config/traces.rb")
		
		def self.load(path)
			config = self.new
			
			if File.exist?(path)
				config.instance_eval(File.read(path), path)
			end
			
			return config
		end
		
		def self.default
			@default ||= self.load(DEFAULT_PATH)
		end
		
		# Prepare the backend, e.g. by loading additional libraries or instrumentation.
		def prepare
		end
		
		# Require a specific trace backend.
		def require_backend(env = ENV)
			if backend = env['TRACES_BACKEND']
				begin
					if require(backend)
						Traces.extend(Backend::Interface)
						
						self.prepare
						
						return true
					end
				rescue LoadError => error
					::Console::Event::Failure.for(error).emit(self, "Unable to load traces backend!", backend: backend, severity: :warn)
				end
			end
			
			return false
		end
		
		# Load the default configuration.
		DEFAULT = self.default
	end
end
