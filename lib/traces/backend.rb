# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

require_relative 'config'

module Traces
	module Backend
	end
	
	Config::DEFAULT.require_backend
end
