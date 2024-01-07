# Getting Started

This guide explains how to use `traces` for tracing code execution.

## Installation

Add the gem to your project:

~~~ bash
$ bundle add traces
~~~

## Core Concepts

`traces` has several core concepts:

- A {ruby Traces::Provider} which implements custom logic for wrapping existing code in traces.
- A {ruby Traces::Context} which represents the current tracing environment which can include distributed tracing.
- A {ruby Traces::Backend} which connects traces to a specific backend system for processing.

## Usage

There are two main aspects to integrating within this gem.

1. Libraries and applications must provide traces.
2. Those traces must be consumed or emitted somewhere.

### Providing Traces

Adding tracing to libraries requires the use of {ruby Traces::Provider}:

~~~ ruby
require 'traces'

class MyClass
	def my_method
		puts "Hello World"
	end
end

# If tracing is disabled, this is a no-op.
Traces::Provider(MyClass) do
	def my_method
		attributes = {
			'foo' => 'bar'
		}
		
		Traces.trace('my_method', attributes: attributes) do
			super
		end
	end
end

MyClass.new.my_method
~~~

This code by itself will not create any traces. In order to execute it and output traces, you must set up a backend to consume them.

### Consuming Traces

Consuming traces means proving a backend implementation which can emit those traces to some log or service. There are several options, but two backends are included by default:

- `traces/backend/test` does not emit any traces, but validates the usage of the tracing interface.
- `traces/backend/console` emits traces using the [`console`](https://github.com/socketry/console) gem.

In order to use a specific backend, set the `TRACES_BACKEND` environment variable, e.g.

~~~ shell
$ TRACES_BACKEND=traces/backend/console ./my_script.rb
~~~

Separate implementations are provided for specific APMs:

- [OpenTelemetry](https://github.com/socketry/traces-backend-open_telemetry)
- [Datadog](https://github.com/socketry/traces-backend-datadog)
- [New Relic](https://github.com/newrelic/traces-backend-newrelic)