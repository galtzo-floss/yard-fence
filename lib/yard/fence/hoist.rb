if ENV.fetch("YARD_FENCE_DISABLE", "false").casecmp?("true")
  warn("[yard/fence/hoist] Hoist disabled via YARD_FENCE_DISABLE")
else
  unless defined?(KramdownGfmDocument)
    # Ensure YARD can resolve the provider constant at the top-level
    # YARD does something akin to Object.const_get("::" + const), so it expects
    # a top-level ::KramdownGfmDocument when const == "KramdownGfmDocument".
    # Provide an alias to our namespaced implementation.
    KramdownGfmDocument = Yard::Fence::KramdownGfmDocument
    puts "[yard/fence/hoist] KramdownGfmDocument hoisted to top-level"
  end
  if defined?(Yard::Fence) && Yard::Fence.respond_to?(:use_kramdown_gfm!)
    if Yard::Fence.use_kramdown_gfm!
      puts "[yard/fence/hoist] Kramdown GFM provider registered"
    else
      warn "[yard/fence/hoist] Kramdown GFM provider registration failed"
    end
  else
    warn("[yard/fence/hoist] Yard::Fence.use_kramdown_gfm! not available; skipping")
  end
end
