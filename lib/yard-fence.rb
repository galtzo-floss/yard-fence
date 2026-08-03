# frozen_string_literal: true

# YARD plugin loader for `--plugin fence`.
# YARD tries requiring several patterns; providing `yard-fence` ensures
# it can be loaded regardless of whether YARD attempts `yard-fence` or `yard/fence`.
require "version_gem"
require_relative "yard/fence/version"

require_relative "yard/fence" unless defined?(::Yard::Fence)

Yard::Fence::Version.class_eval do
  extend VersionGem::Basic
end
