# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

unless ENV["TRACES_BACKEND"]
	abort "No backend specified, tests will fail!"
end

require "traces"
require "traces/context"
require "json"

describe Traces::Context do
	let(:trace_id) {"496e95c5964f7cb924fc820a469a9f74"}
	let(:parent_id) {"ae9b1d95d29fe974"}
	let(:trace_parent) {"00-496e95c5964f7cb924fc820a469a9f74-ae9b1d95d29fe974-0"}
	let(:flags) {0}
	
	with ".local" do
		it "should create a trace context" do
			context = Traces::Context.local
			
			expect(context.trace_id).to be =~ /\h{32}/
			expect(context.parent_id).to be =~ /\h{16}/
			expect(context.flags).to be == 0
			expect(context.state).to be == nil
		end
	end
	
	with "#nested" do
		it "can nest contexts" do
			parent = Traces::Context.local
			child = parent.nested
			
			expect(parent.trace_id).to be == child.trace_id
		end
	end
	
	with ".nested" do
		with "a local parent context" do
			it "can nest contexts" do
				parent = Traces::Context.local
				child = Traces::Context.nested(parent)
				
				expect(parent.trace_id).to be == child.trace_id
			end
		end
		
		with "no parent context" do
			it "can nest contexts" do
				child = Traces::Context.nested(nil)
				
				expect(child).not.to be == nil
			end
		end
	end
	
	with "#to_s" do
		it "can be converted to string" do
			context = Traces::Context.new(trace_id, parent_id, 0)
			
			expect(context.to_s).to be == trace_parent
		end
	end
	
	with "#to_json" do
		it "can be converted to JSON" do
			context = Traces::Context.new(trace_id, parent_id, 0)
			
			text = context.to_json
			
			expect(JSON.parse(text)).to have_keys(
				"trace_id" => be == trace_id,
				"parent_id" => be == parent_id,
				"flags" => be == 0,
			)
		end
	end
	
	with ".parse" do
		let(:trace_state) {nil}
		let(:baggage) {nil}
		let(:context) {Traces::Context.parse(trace_parent, trace_state, baggage)}
		
		it "can extract trace context from string" do
			expect(context.trace_id).to be == trace_id
			expect(context.parent_id).to be == parent_id
			expect(context.flags).to be == flags
			expect(context.sampled?).to be == false
			expect(context).not.to be(:remote?)
		end
		
		with "trace state", trace_state: "foo=bar" do
			it "can extract trace context from string" do
				expect(context.state).to be == {"foo" => "bar"}
			end
		end
		
		with "baggage", baggage: "user_id=123,session=abc" do
			it "can extract baggage from string" do
				expect(context.baggage).to be == {"user_id" => "123", "session" => "abc"}
			end
		end
		
		with "baggage array", baggage: ["user_id=123", "session=abc"] do
			it "can extract baggage from array" do
				expect(context.baggage).to be == {"user_id" => "123", "session" => "abc"}
			end
		end
	end
	
	with "baggage functionality" do
		let(:trace_id) {"496e95c5964f7cb924fc820a469a9f74"}
		let(:parent_id) {"ae9b1d95d29fe974"}
		let(:baggage) {{"user_id" => "123", "session" => "abc", "team" => "backend"}}
		
		it "can initialize with baggage" do
			context = Traces::Context.new(trace_id, parent_id, 0, nil, baggage)
			expect(context.baggage).to be == baggage
		end
		
		it "can initialize without baggage" do
			context = Traces::Context.new(trace_id, parent_id, 0)
			expect(context.baggage).to be == nil
		end
		
		it "propagates baggage to nested contexts" do
			parent = Traces::Context.new(trace_id, parent_id, 0, nil, baggage)
			child = parent.nested
			
			expect(child.baggage).to be == baggage
			expect(child.trace_id).to be == trace_id
		end
		
		it "includes baggage in JSON representation" do
			context = Traces::Context.new(trace_id, parent_id, 0, nil, baggage)
			json = context.as_json
			
			expect(json[:baggage]).to be == baggage
		end
		
		with "#inject" do
			it "injects baggage into headers" do
				context = Traces::Context.new(trace_id, parent_id, 0, nil, baggage)
				headers = {}
				
				context.inject(headers)
				
				expect(headers["baggage"]).not.to be == nil
				expect(headers["baggage"]).to be =~ /user_id=123/
				expect(headers["baggage"]).to be =~ /session=abc/
				expect(headers["baggage"]).to be =~ /team=backend/
			end
			
			it "does not inject empty baggage" do
				context = Traces::Context.new(trace_id, parent_id, 0, nil, {})
				headers = {}
				
				context.inject(headers)
				
				expect(headers["baggage"]).to be == nil
			end
			
			it "does not inject nil baggage" do
				context = Traces::Context.new(trace_id, parent_id, 0, nil, nil)
				headers = {}
				
				context.inject(headers)
				
				expect(headers["baggage"]).to be == nil
			end
		end
		
		with ".extract" do
			it "extracts baggage from headers" do
				headers = {
					"traceparent" => "00-#{trace_id}-#{parent_id}-0",
					"baggage" => "user_id=123,session=abc,team=backend"
				}
				
				context = Traces::Context.extract(headers)
				
				expect(context.baggage).to be == baggage
				expect(context.remote?).to be == true
			end
			
			it "extracts empty baggage gracefully" do
				headers = {
					"traceparent" => "00-#{trace_id}-#{parent_id}-0",
					"baggage" => ""
				}
				
				context = Traces::Context.extract(headers)
				
				expect(context.baggage).to be == {}
			end
			
			it "works without baggage header" do
				headers = {
					"traceparent" => "00-#{trace_id}-#{parent_id}-0"
				}
				
				context = Traces::Context.extract(headers)
				
				expect(context.baggage).to be == nil
			end
			
			it "handles baggage with special characters" do
				headers = {
					"traceparent" => "00-#{trace_id}-#{parent_id}-0",
					"baggage" => "key%20with%20space=value%20with%20space,special=test%3Dvalue"
				}
				
				context = Traces::Context.extract(headers)
				
				expect(context.baggage).to be == {
					"key%20with%20space" => "value%20with%20space",
					"special" => "test%3Dvalue"
				}
			end
		end
		
		with "round trip inject/extract" do
			it "preserves baggage through inject and extract" do
				original_context = Traces::Context.new(trace_id, parent_id, 0, nil, baggage)
				headers = {}
				
				# Inject:
				original_context.inject(headers)
				
				# Extract:
				extracted_context = Traces::Context.extract(headers)
				
				expect(extracted_context.baggage).to be == original_context.baggage
				expect(extracted_context.trace_id).to be == original_context.trace_id
				expect(extracted_context.parent_id).to be == original_context.parent_id
			end
			
			it "preserves both state and baggage together" do
				state = {"vendor" => "custom", "sampling" => "1"}
				original_context = Traces::Context.new(trace_id, parent_id, 1, state, baggage)
				headers = {}
				
				# Inject:
				original_context.inject(headers)
				
				# Extract:
				extracted_context = Traces::Context.extract(headers)
				
				expect(extracted_context.state).to be == original_context.state
				expect(extracted_context.baggage).to be == original_context.baggage
				expect(extracted_context.flags).to be == original_context.flags
			end
		end
		
		with "integration with Traces.inject/extract" do
			it "preserves baggage through Traces inject/extract methods" do
				Traces.trace("test") do
					# Create context with baggage
					context_with_baggage = Traces::Context.new(trace_id, parent_id, 0, nil, baggage)
					headers = {}
					
					# Use the backend inject method
					Traces.inject(headers, context_with_baggage)
					
					# Should have baggage header
					expect(headers["baggage"]).not.to be == nil
					
					# Extract using backend method:
					extracted_context = Traces.extract(headers)
					
					# Should preserve baggage
					expect(extracted_context.baggage).to be == baggage
				end
			end
			
			it "handles missing baggage gracefully in inject" do
				context_without_baggage = Traces::Context.new(trace_id, parent_id, 0)
				headers = {}
				
				Traces.inject(headers, context_without_baggage)
				
				# Should not have baggage header
				expect(headers["baggage"]).to be == nil
			end
		end
	end
end

describe Traces do
	with "#current_context" do
		it "returns nil trace context when no active trace" do
			# Clear any existing context first
			Traces.trace_context = nil
			current = Traces.current_context
			expect(current).to be == nil
		end
		
		it "captures current trace context when active" do
			Traces.trace("test") do
				current = Traces.current_context
				expect(current).not.to be == nil
				expect(current).to be == Traces.trace_context
			end
		end
		
		it "captures trace context at the time current is called" do
			outer_current = nil
			inner_current = nil
			
			Traces.trace("outer") do
				outer_current = Traces.current_context
				
				Traces.trace("inner") do
					inner_current = Traces.current_context
				end
			end
			
			expect(outer_current).not.to be == inner_current
		end
		
		it "creates independent current objects" do
			Traces.trace("test") do
				current1 = Traces.current_context
				current2 = Traces.current_context
				
				# Since current_context returns trace_context directly, 
				# they should be the same object
				expect(current1).to be_equal(current2)
			end
		end
		
		it "isolates context between fibers" do
			main_current = nil
			fiber_current = nil
			
			Traces.trace("main") do
				main_current = Traces.current_context
				
				Fiber.new do
					# Fiber should start with no context
					expect(Traces.current_context).to be == nil
					
					Traces.trace("fiber") do
						fiber_current = Traces.current_context
					end
				end.resume
			end
			
			expect(main_current).not.to be == fiber_current
		end
	end
	
	with "#with_context" do
		it "can restore trace context from current" do
			captured_current = nil
			
			# Clear any existing context first
			Traces.trace_context = nil
			
			# First, capture a trace context
			Traces.trace("original") do
				captured_current = Traces.current_context
			end
			
			# After trace, context remains (trace doesn't auto-restore previous context)
			expect(Traces.trace_context).to be == captured_current
			
			# Clear context to test restoration
			Traces.trace_context = nil
			expect(Traces.trace_context).to be == nil
			
			# Restore the context and verify it's the same
			Traces.with_context(captured_current) do
				expect(Traces.trace_context).to be == captured_current
			end
		end
		
		it "restores previous context after block" do
			# Clear any existing context first
			Traces.trace_context = nil
			original_context = Traces.trace_context
			
			Traces.trace("test") do
				current = Traces.current_context
				
				# Clear context, then restore with with_context
				Traces.trace_context = nil
				
				Traces.with_context(current) do
					# Inside block should have the restored context
					expect(Traces.trace_context).to be == current
				end
				
				# After block, should be back to nil (what was set before with_context)
				expect(Traces.trace_context).to be == nil
			end
		end
		
		it "can be called without a block" do
			captured_current = nil
			
			Traces.trace("test") do
				captured_current = Traces.current_context
			end
			
			# Clear context
			Traces.trace_context = nil
			expect(Traces.trace_context).to be == nil
			
			# Set context without block (permanent switch)
			Traces.with_context(captured_current)
			expect(Traces.trace_context).to be == captured_current
		end
		
		it "handles nil context gracefully" do
			Traces.trace("test") do
				# Should be able to switch to nil context
				Traces.with_context(nil) do
					expect(Traces.trace_context).to be == nil
				end
			end
		end
		
		it "can nest with_context calls" do
			first_current = nil
			second_current = nil
			
			Traces.trace("first") do
				first_current = Traces.current_context
				
				Traces.trace("second") do
					second_current = Traces.current_context
				end
			end
			
			# Clear context to start fresh
			Traces.trace_context = nil
			
			# Nested with_context calls
			Traces.with_context(first_current) do
				expect(Traces.trace_context).to be == first_current
				
				Traces.with_context(second_current) do
					expect(Traces.trace_context).to be == second_current
				end
				
				# Should be back to first context
				expect(Traces.trace_context).to be == first_current
			end
		end
	end
	
	with "#inject" do
		it "can inject current context into headers" do
			headers = {}
			
			Traces.trace("test") do
				current = Traces.current_context
				Traces.inject(headers, current)
			end
			
			expect(headers["traceparent"]).not.to be == nil
			expect(headers["traceparent"]).to be =~ /^00-[0-9a-f]{32}-[0-9a-f]{16}-[0-9a-f]{1,2}$/
		end
		
		it "can inject nil context (uses current trace_context)" do
			headers = {}
			
			Traces.trace("test") do
				Traces.inject(headers)
			end
			
			expect(headers["traceparent"]).not.to be == nil
			expect(headers["traceparent"]).to be =~ /^00-[0-9a-f]{32}-[0-9a-f]{16}-[0-9a-f]{1,2}$/
		end
		
		it "does nothing when no context available" do
			# Clear any existing context first
			Traces.trace_context = nil
			headers = {}
			Traces.inject(headers)
			
			expect(headers).to be == {}
		end
		
		it "creates new headers hash when called without arguments" do
			Traces.trace("test") do
				# Call inject with no arguments - should create new hash
				result = Traces.inject()
				
				expect(result).to be_a(Hash)
				expect(result["traceparent"]).not.to be == nil
			end
		end
		
		it "returns nil when called without arguments and no active trace" do
			# Clear any existing context first
			Traces.trace_context = nil
			
			result = Traces.inject()
			
			expect(result).to be == nil
		end
		
		it "mutates the headers hash" do
			headers = {"Content-Type" => "application/json"}
			original_headers = headers
			
			Traces.trace("test") do
				result = Traces.inject(headers, Traces.current_context)
				expect(result).to be_equal(headers)
			end
			
			expect(headers["traceparent"]).not.to be == nil
			expect(headers["Content-Type"]).to be == "application/json"
		end
		
		
	end
	
	with "#extract" do
		it "can extract context from headers" do
			original_context = nil
			headers = {}
			
			# First, inject a context
			Traces.trace("test") do
				original_context = Traces.current_context
				Traces.inject(headers, original_context)
			end
			
			# Then extract it
			extracted_context = Traces.extract(headers)
			
			expect(extracted_context).not.to be == nil
			expect(extracted_context.trace_id).to be == original_context.trace_id
		end
		
		it "can be used with with_context" do
			original_context = nil
			headers = {}
			executed = false
			
			# Inject context:
			Traces.trace("test") do
				original_context = Traces.current_context
				Traces.inject(headers, original_context)
			end
			
			# Extract and use with with_context:
			extracted_context = Traces.extract(headers)
			Traces.with_context(extracted_context) do
				executed = true
				expect(Traces.trace_context.trace_id).to be == original_context.trace_id
			end
			
			expect(executed).to be == true
		end
		
		it "returns nil when no traceparent header" do
			headers = {"Content-Type" => "application/json"}
			context = Traces.extract(headers)
			
			expect(context).to be == nil
		end
		
		
		
		it "returns nil for malformed traceparent" do
			headers = {"traceparent" => "invalid-format"}
			
			result = Traces.extract(headers)
			expect(result).to be == nil
		end
	end
	
	with "#inject and #extract round trip" do
		it "preserves context through round trip" do
			original_headers = {}
			extracted_context = nil
			
			# Create and inject context
			Traces.trace("parent") do
				current = Traces.current_context
				Traces.inject(original_headers, current)
				
				# Extract context:
				extracted_context = Traces.extract(original_headers)
			end
			
			# Use extracted context
			Traces.with_context(extracted_context) do
				Traces.trace("child") do
					# Should be able to create child spans with extracted context
					expect(Traces.trace_context).not.to be == nil
				end
			end
		end
	end
end
