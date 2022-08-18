# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :test do
	gem "console"
	gem "ddtrace"
	
	gem "sus"
end

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-gem"
	
	gem "bake-github-pages"
	gem "utopia-project"
end
