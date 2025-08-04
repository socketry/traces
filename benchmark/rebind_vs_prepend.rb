# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2025, by Samuel Williams.

require "benchmark/ips"

class MyClass1
	def my_method
		true
	end
end

module Tracer1
	def my_method(...)
		super
	end
end

MyClass1.prepend(Tracer1)

class MyClass2
	def my_method
		true
	end
end

module Tracer2
	def trace(name)
		original_method = instance_method(name)
		trace_provider = @trace_provider
		
		remove_method(name)
		
		define_method(name) do |*arguments, &block|
			original_method.bind(self).call(*arguments, &block)
		end
		
		ruby2_keywords(name)
	end
end

MyClass2.extend(Tracer2)
MyClass2.trace(:my_method)

module Trace
	module Provider
		def trace_provider
			@trace_provider ||= Module.new
		end
		
		def trace(name)
			trace_provider.module_eval "def #{name}(...); super; end"
		end
	end
	
	def self.Provider(klass)
		klass.extend(Provider)
		klass.prepend(klass.trace_provider)
	end
end

class MyClass3
	Trace::Provider(self)
	
	trace def my_method
		true
	end
end

Benchmark.ips do |x|
	x.report("MyClass1", "MyClass1.new.my_method")
	x.report("MyClass2", "MyClass2.new.my_method")
	x.report("MyClass3", "MyClass3.new.my_method")
	
	x.compare!
end
