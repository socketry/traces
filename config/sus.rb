ENV['TRACES_BACKEND'] ||= 'traces/backend/console'

require 'covered/sus'
include Covered::Sus
