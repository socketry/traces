$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

ENV['TRACES_BACKEND'] ||= 'traces/backend/console'

require "bundler/setup"
