# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :test do
	gem "console"
	gem "ddtrace"
end

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-gem"
	
	gem "utopia-project"
end
