# frozen_string_literal: true

# Ensure local lib is on $LOAD_PATH so we can dogfood this gem without installing it.
lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

if defined?(Yard::Fence) && Yard::Fence.respond_to?(:use_kramdown_gfm!)
  if Yard::Fence.use_kramdown_gfm!
    puts "[yard_bootstrap] Kramdown GFM provider registered"
  else
    warn "[yard_bootstrap] Kramdown GFM provider registration failed"
  end
else
  warn("[yard_bootstrap] Yard::Fence.use_kramdown_gfm! not available; skipping")
end
