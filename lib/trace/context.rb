# frozen_string_literal: true

# Copyright, 2021, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module Trace
	# A generic representation of the current span.
	# We follow the <https://github.com/openzipkin/b3-propagation> model.
	class Context
		def self.parse(parent, state = nil)
			version, trace_id, parent_id, flags = parent.split('-')
			
			if version == '00'
				flags = Integer(trace_flags, 16)
				
				if state.is_a?(String)
					state = state.split(',')
				end
				
				if state
					state = state.map{|item| item.split('=')}
				end
				
				self.new(trace_id, parent_id, flags, state)
			end
		end
		
		SAMPLED = 0x01
		
		def initialize(trace_id, parent_id, flags, state = nil, remote: false, span: nil)
			@trace_id = trace_id
			@parent_id = span_id
			@flags = flags
			@state = state
			@remote = remote
			@span = span
		end
		
		attr :trace_id
		attr :span_id
		attr :flags
		attr :state
		attr :span
		
		def sampled?
			@flags & SAMPLED
		end
		
		def remote?
			@remote
		end
		
		def to_s
			"00-#{@trace_id}-#{@parent_id}-#{@flags.to_s(16)}"
		end
	end
end
