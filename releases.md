# Releases

## v0.14.0

### Introduce `Traces::Config` to control tracing behavior

There are some reasonable defaults for tracing, but sometimes you want to change them. Adding a `config/traces.rb` file to your project will allow you to do that.

``` ruby
# config/traces.rb

def prepare
	require 'traces/provider/async'
	require 'traces/provider/async/http'
end
```

The `prepare` method is called before the tracing is started but after the backend is required. You can require any provider you want in this file, or even add your own custom providers.
