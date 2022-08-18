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

require 'traces/context'

describe Traces::Context do
	let(:trace_id) {"496e95c5964f7cb924fc820a469a9f74"}
	let(:parent_id) {"ae9b1d95d29fe974"}
	let(:trace_parent) {"00-496e95c5964f7cb924fc820a469a9f74-ae9b1d95d29fe974-0"}
	let(:flags) {0}

	with '.local' do
		it 'should create a trace context' do
			context = Traces::Context.local
			
			expect(context.trace_id).to be =~ /\h{32}/
			expect(context.parent_id).to be =~ /\h{16}/
			expect(context.flags).to be == 0
			expect(context.state).to be == nil
		end
	end
	
	with '#nested' do
		it 'can nest contexts' do
			parent = Traces::Context.local
			child = parent.nested
			
			expect(parent.trace_id).to be == child.trace_id
		end
	end
	
	with '.nested' do
		with 'a local parent context' do
			it 'can nest contexts' do
				parent = Traces::Context.local
				child = Traces::Context.nested(parent)
				
				expect(parent.trace_id).to be == child.trace_id
			end
		end
		
		with 'no parent context' do
			it 'can nest contexts' do
				child = Traces::Context.nested(nil)
				
				expect(child).not.to be == nil
			end
		end
	end
	
	with '#to_s' do
		it 'can be converted to string' do
			context = Traces::Context.new(trace_id, parent_id, 0)
			
			expect(context.to_s).to be == trace_parent
		end
	end
	
	with '.parse' do
		let(:trace_state) {nil}
		let(:context) {Traces::Context.parse(trace_parent, trace_state)}
		
		it 'can extract trace context from string' do
			expect(context.trace_id).to be == trace_id
			expect(context.parent_id).to be == parent_id
			expect(context.flags).to be == flags
			expect(context.sampled?).to be == false
		end
		
		with 'trace state', trace_state: 'foo=bar' do
			it 'can extract trace context from string' do
				expect(context.state).to be == {'foo' => 'bar'}
			end
		end
	end
end