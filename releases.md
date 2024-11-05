# Releases

## v0.14.0

### Introduce `Traces::Config` to Expose `prepare` Hook

The `traces` gem uses aspect-oriented programming to wrap existing methods to emit traces. However, while there are some reasonable defaults for emitting traces, it can be useful to customize the behavior and level of detail. To that end, the `traces` gem now optionally loads a `config/traces.rb` which includes a `prepare` hook that can be used to load additional providers.

``` ruby
# config/traces.rb

def prepare
	require 'traces/provider/async'
	require 'traces/provider/async/http'
end
```

The `prepare` method is called immediately after the traces backend is loaded. You can require any provider you want in this file, or even add your own custom providers.
