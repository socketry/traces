# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "traces/provider"
require "json"

describe Traces::Provider do
	let(:document_root) {File.expand_path(".capture", __dir__)}
	let(:environment) {{"TRACES_BACKEND" => nil}}
	
	it "runs without traces" do
		pid = Process.spawn(environment, "bundle", "exec", "bake", "run", chdir: document_root)
		pid, status = Process.wait2(pid)
		
		expect(status).to be(:success?)
	end
	
	it "can list all traces" do
		input, output = IO.pipe
		
		pid = Process.spawn(environment, "bundle", "exec", "bake", "traces:capture", "run", "traces:capture:list", "output", "--format", "json", chdir: document_root, out: output)
		output.close
		Process.wait(pid)
		
		traces = JSON.parse(input.read)
		
		expect(traces).to be_a(Array)
		trace = traces[0]
		
		expect(trace).to have_keys(
			"name" => be == "my_trace",
			"resource" => be == "my_resource",
			"attributes" => be == {"foo" => "baz"},
		)
	end
end
