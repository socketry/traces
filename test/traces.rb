# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

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
		Traces.trace('my_method', attributes: {argument: argument}) {super}
	end
	
	def my_method_with_result(result)
		Traces.trace('my_method_with_result') do |span|
			super.tap do |result|
				span["result"] = result
			end
		end
	end
	
	def my_method_with_attributes(attributes)
		Traces.trace('my_method_with_attributes', attributes: attributes) {super}
	end
end

Traces::Provider(MySubClass) do
	def my_other_method(argument)
		Traces.trace('my_other_method', attributes: {argument: argument}) {super}
	end
end

describe Traces do
	it "has a version number" do
		expect(Traces::VERSION).to be =~ /\d+\.\d+\.\d+/
	end
	
	describe MyClass do
		let(:instance) {MyClass.new}
		
		it "can invoke trace wrapper" do
			expect(Traces).to receive(:trace)
			
			expect(instance.my_method(10)).to be == 10
		end
		
		with 'result' do
			let(:result) {"result"}
			
			it "can invoke trace wrapper" do
				expect(Traces).to receive(:trace)
				
				expect(instance.my_method_with_result(result)).to be == result
			end
		end
		
		with 'attributes' do
			let(:attributes) {{"name" => "value"}}
			
			it "can invoke trace wrapper" do
				expect(Traces).to receive(:trace)
				
				expect(instance.my_method_with_attributes(attributes)).to be == attributes
			end
		end
		
		with 'parent trace context' do
			let(:context) {Traces::Context.local}
			
			it "can create child trace context" do
				Traces.trace_context = context
				expect(Traces.trace_context).to be == context
			end
		end
	end
	
	describe MySubClass do
		let(:instance) {MySubClass.new}
		
		it "can invoke trace wrapper" do
			expect(Traces).to receive(:trace)
			
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
				expect(Traces).to receive(:trace)
				
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
				expect(Traces).to receive(:trace)
				
				expect do
					instance.my_method_with_attributes(attributes)
				end.to raise_exception(ArgumentError)
			end
		end
		
		with 'missing block' do
			it "fails with exception" do
				expect do
					Traces.trace('foo')
				end.to raise_exception(ArgumentError)
			end		
		end
		
		with 'invalid name' do
			it "fails with exception" do
				expect do
					Traces.trace(Object.new) {}
				end.to raise_exception(ArgumentError)
			end		
		end
	end 
end
