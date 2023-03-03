# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

def capture
	ENV['TRACES_BACKEND'] = 'traces/backend/capture'
	require 'traces'
end

# Generate a list of metrics using the document backend.
def list
	Traces::Backend::Capture.spans.sort_by!{|span| span.name}
end
