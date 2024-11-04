# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2023, by Samuel Williams.

require "traces/backend"
require "json"

require "sus/fixtures/console"

describe Traces::Config do
	let(:config) {subject.default}
	
	with ".require_backend" do
		include_context Sus::Fixtures::Console::CapturedLogger
		
		it "logs a warning if backend cannot be loaded" do
			expect(
				config.require_backend({"TRACES_BACKEND" => "traces/backend/missing"})
			).to be == false
			
			expect_console.to have_logged(
				severity: be == :warn,
			)
		end
	end
end
