# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-gem"
	
	gem "bake-github-pages"
	gem "utopia-project"
end

group :test do
	gem "bake-test"
	gem "bake-test-external"

	gem "console"
	gem "ddtrace"
	
	gem "sus"	
end
