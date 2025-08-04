# frozen_string_literal: true

require_relative "lib/traces/version"

Gem::Specification.new do |spec|
	spec.name = "traces"
	spec.version = Traces::VERSION
	
	spec.summary = "Application instrumentation and tracing."
	spec.authors = ["Samuel Williams", "Felix Yan", "Zach Taylor"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/socketry/traces"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/traces/",
		"source_code_uri" => "https://github.com/socketry/traces.git",
	}
	
	spec.files = Dir.glob(["{lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.2"
end
