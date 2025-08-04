# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require "traces/config"
require "json"

describe Traces::Config do
	let(:config) {subject.default}
	
	with ".require_backend" do
		it "logs a warning if backend cannot be loaded" do
			expect(config).to receive(:warn).and_return(nil)
			
			expect(
				config.require_backend({"TRACES_BACKEND" => "traces/backend/missing"})
			).to be == false
		end
	end
end
