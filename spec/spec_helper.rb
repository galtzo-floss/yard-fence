# frozen_string_literal: true

# Start coverage as early as possible for deterministic results
begin
  require "kettle-soup-cover"
  require "simplecov" if Kettle::Soup::Cover::DO_COV # `.simplecov` is run here!
rescue LoadError => error
  # check the error message, and re-raise if not what is expected
  raise error unless error.message.include?("kettle")
end

require "kettle/test/rspec"

# Library Configs
require_relative "config/debug"

# Deterministic environment for tests
ENV["YARD_DEBUG"] = "false"
ENV["YARD_FENCE_SKIP_AT_EXIT"] = "1"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Deterministic order to stabilize coverage
  config.order = :defined

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Stabilize YARD Markup providers between examples to avoid order-dependent variability.
  config.around(:each) do |example|
    snapshot = nil
    begin
      if defined?(::YARD::Templates::Helpers::MarkupHelper) &&
         ::YARD::Templates::Helpers::MarkupHelper::MARKUP_PROVIDERS.is_a?(Hash) &&
         ::YARD::Templates::Helpers::MarkupHelper::MARKUP_PROVIDERS.key?(:markdown)
        providers = ::YARD::Templates::Helpers::MarkupHelper::MARKUP_PROVIDERS[:markdown]
        snapshot = providers.map { |h| h.dup }
      end
    rescue NameError
      snapshot = nil
    end

    example.run
  ensure
    if snapshot
      begin
        ::YARD::Templates::Helpers::MarkupHelper::MARKUP_PROVIDERS[:markdown].replace(snapshot)
      rescue NameError
        # Constant may have been hidden in the example; it will restore after.
      end
    end
  end
end

require "yard" # yard loads .yardopts, which loads this plugin!
