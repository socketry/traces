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
