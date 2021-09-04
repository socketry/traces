# Trace

As the author of many libraries which would benefit from tracing, there are few key priorities: (1) zero overhead if tracing is disabled, minimal overhead if enabled, and (2) a small and opinionated interface with standardised semantics. This gem provide such an interface.

We implement a tracing interface which is largely consistent with the [W3C Trace Context Specification](https://github.com/w3c/trace-context).

## Installation

```
bundle add trace
```

## Usage

```ruby
require 'trace'

class MyClass
	def my_method
		puts "Hello World"
	end
end

# If tracing is disabled, this is a no-op.
Trace::Provider(MyClass) do
	def my_method
		attributes = {
			'foo' => 'bar'
		}
		
		trace('my_method', attributes: attributes) do
			super
		end
	end
end

MyClass.new.my_method
```

If tracing is disabled, there is no overhead.

## Contributing

We welcome contributions to this project.

1.  Fork it
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create new Pull Request

## License

Released under the MIT license.

Copyright, 2021, by [Samuel G. D. Williams](http://www.codeotaku.com).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
