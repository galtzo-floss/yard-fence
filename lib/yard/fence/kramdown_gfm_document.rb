# YARD GFM support shim: ensure Kramdown GFM provider is first in the provider list
# so markdown code fences and GitHub-style markdown render as expected. This does not
# alter content; it influences the order in which YARD tries markdown engines.
# See test_gfm.rb for a quick sanity check of provider order and <pre><code> rendering.

# Gratefully and liberally taken from the MIT-licensed https://github.com/bensheldon/good_job/pull/113/files
require "kramdown"
require "kramdown-parser-gfm"

# Custom markup provider class that always renders Kramdown using GFM (Github Flavored Markdown).
# GFM is needed to render markdown tables and fenced code blocks in the README.
module Yard
  module Fence
    class KramdownGfmDocument < Kramdown::Document
      def initialize(source, options = {})
        options[:input] = "GFM" unless options.key?(:input)
        super(source, options)
      end
    end
  end
end

# Note:
# We intentionally do NOT auto-register here to avoid circular require warnings when
# YARD is loading. Prefer calling Yard::Fence.use_kramdown_gfm! from your .yardopts.
