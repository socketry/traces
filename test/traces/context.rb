# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2023, by Samuel Williams.

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
	
	with '#to_json' do
		it 'can be converted to JSON' do
			context = Traces::Context.new(trace_id, parent_id, 0)
			
			text = context.to_json
			
			expect(JSON.parse(text)).to have_keys(
				'trace_id' => be == trace_id,
				'parent_id' => be == parent_id,
				'flags' => be == 0,
			)
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
			expect(context).not.to be(:remote?)
		end
		
		with 'trace state', trace_state: 'foo=bar' do
			it 'can extract trace context from string' do
				expect(context.state).to be == {'foo' => 'bar'}
			end
		end
	end
end
