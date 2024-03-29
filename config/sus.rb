# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

ENV['TRACES_BACKEND'] ||= 'traces/backend/console'

require 'covered/sus'
include Covered::Sus
