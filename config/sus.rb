# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

ENV["TRACES_BACKEND"] ||= "traces/backend/test"

require "covered/sus"
include Covered::Sus
