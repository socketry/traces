# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2023, by Samuel Williams.

require "traces/context"
require "json"

require "sus/fixtures/console"

describe Traces do
	with ".require_backend" do
		include_context Sus::Fixtures::Console::CapturedLogger
		
		it "logs a warning if backend cannot be loaded" do
			subject.require_backend({"TRACES_BACKEND" => "traces/backend/missing"})
		end
	end
end
