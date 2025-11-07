if defined?(Yard::Fence) && Yard::Fence.respond_to?(:use_kramdown_gfm!)
  if Yard::Fence.use_kramdown_gfm!
    puts "[yard/fence/hoist] Kramdown GFM provider registered"
  else
    warn "[yard/fence/hoist] Kramdown GFM provider registration failed"
  end
else
  warn("[yard/fence/hoist] Yard::Fence.use_kramdown_gfm! not available; skipping")
end
