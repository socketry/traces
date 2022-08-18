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

require 'traces'

class MyClass
	def my_method(argument)
		argument
	end
	
	def my_method_with_result(result)
		result
	end
	
	def my_method_with_attributes(attributes)
		attributes
	end
end

class MySubClass < MyClass
	def my_method(argument)
		super * 2
	end
	
	def my_other_method(argument)
		argument
	end
end

Traces::Provider(MyClass) do
	def my_method(argument)
		trace('my_method', attributes: {argument: argument}) {super}
	end
	
	def my_method_with_result(result)
		trace('my_method_with_result') do |span|
			super.tap do |result|
				span["result"] = result
			end
		end
	end
	
	def my_method_with_attributes(attributes)
		trace('my_method_with_attributes', attributes: attributes) {super}
	end
end

Traces::Provider(MySubClass) do
	def my_other_method(argument)
		trace('my_other_method', attributes: {argument: argument}) {super}
	end
end

describe Traces do
	it "has a version number" do
		expect(Traces::VERSION).to be =~ /\d+\.\d+\.\d+/
	end
	
	describe MyClass do
		let(:instance) {MyClass.new}
		
		it "can invoke trace wrapper" do
			expect(instance).to receive(:trace)
			
			expect(instance.my_method(10)).to be == 10
		end
		
		with 'result' do
			let(:result) {"result"}
			
			it "can invoke trace wrapper" do
				expect(instance).to receive(:trace)
				
				expect(instance.my_method_with_result(result)).to be == result
			end
		end
		
		with 'attributes' do
			let(:attributes) {{"name" => "value"}}
			
			it "can invoke trace wrapper" do
				expect(instance).to receive(:trace)
				
				expect(instance.my_method_with_attributes(attributes)).to be == attributes
			end
		end
		
		with 'parent trace context' do
			let(:context) {Traces::Context.local}
			
			it "can create child trace context" do
				instance.trace_context = context
				expect(instance.trace_context).to be == context
			end
		end
	end
	
	describe MySubClass do
		let(:instance) {MySubClass.new}
		
		it "can invoke trace wrapper" do
			expect(instance).to receive(:trace)
			
			expect(instance.my_method(10)).to be == 20
		end
		
		it "does not affect the base class" do
			expect(MyClass.new).not.to respond_to(:my_other_method)
		end
	end
end

if defined?(Traces::Backend::Test)
	describe Traces do
		let(:instance) {MyClass.new}
		
		with 'invalid attribute key' do
			let(:attributes) {{Object.new => "value"}}
			
			it "fails with exception" do
				expect(instance).to receive(:trace)
				
				expect do
					instance.my_method_with_attributes(attributes)
				end.to raise_exception(ArgumentError)
			end
		end
		
		with 'invalid attribute value' do
			let(:value) do
				Object.new.tap do |object|
					object.singleton_class.undef_method :to_s
				end
			end
			
			let(:attributes) {{"key" => value}}
			
			it "fails with exception" do
				expect(instance).to receive(:trace)
				
				expect do
					instance.my_method_with_attributes(attributes)
				end.to raise_exception(ArgumentError)
			end
		end
		
		with 'missing block' do
			it "fails with exception" do
				expect do
					instance.trace('foo')
				end.to raise_exception(ArgumentError)
			end		
		end
		
		with 'invalid name' do
			it "fails with exception" do
				expect do
					instance.trace(Object.new) {}
				end.to raise_exception(ArgumentError)
			end		
		end
	end 
end
