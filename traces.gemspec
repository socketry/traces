# frozen_string_literal: true

require_relative "lib/traces/version"

Gem::Specification.new do |spec|
	spec.name = "traces"
	spec.version = Traces::VERSION
	
	spec.summary = "Application instrumentation and tracing."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/socketry/traces"
	
	spec.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.add_development_dependency "rspec", "~> 3.0"
end
