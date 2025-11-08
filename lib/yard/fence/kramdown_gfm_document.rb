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
      # Detects an unrendered fenced code block that slipped through HTML generation.
      # Note on <details markdown="1">:
      # - The classic kramdown parser honors the markdown="1" attribute on block HTML like <details>,
      #   and will parse contained markdown as block-level content.
      # - The GFM parser generally handles many cases well, and markdown="1" may appear to work in
      #   most sections; however, we've observed edge cases where fenced code blocks inside a
      #   <details markdown="1"> are left as literal backticks (rendered as <p>``` …</p>).
      #   This fallback detects that situation and re-renders with the classic parser.
      UNRENDERED_FENCE_PARAGRAPH = /<p>```/
      DETAILS_MARKDOWN_1 = /<details[^>]*markdown=["']1["'][^>]*>/i

      def initialize(source, options = {})
        options[:input] = "GFM" unless options.key?(:input)
        @__yard_fence_source = source # Keep original for potential fallback.
        super(source, options)
      end

      # Override to_html to provide a smart fallback: if the GFM parse leaves literal
      # fenced code markers (```), re-run the render with the classic 'kramdown' input which
      # correctly evaluates markdown inside <details markdown="1"> blocks.
      # Opt-out via ENV["YARD_FENCE_DISABLE_FALLBACK"] == "1".
      def to_html
        html = super
        return html if ENV["YARD_FENCE_DISABLE_FALLBACK"] == "1"
        return html unless @__yard_fence_source.include?("```")

        if needs_fallback?(html)
          fallback_options = @options.merge(input: "kramdown")
          fb_html = Kramdown::Document.new(@__yard_fence_source, fallback_options).to_html
          return fb_html if fallback_improved?(fb_html)
        end
        html
      end

      private

      def needs_fallback?(html)
        # Obvious failure: raw fenced code rendered as a paragraph
        return true if html.match?(UNRENDERED_FENCE_PARAGRAPH)
        # Edge case: details wrapper present in source but output lacks any code block
        if @__yard_fence_source.match?(DETAILS_MARKDOWN_1)
          has_code_block = html.include?("<pre") && html.include?("<code")
          return !has_code_block
        end
        false
      end

      def fallback_improved?(fb_html)
        fb_html.match?(UNRENDERED_FENCE_PARAGRAPH) == false &&
          fb_html.include?("<pre") && fb_html.include?("<code")
      end
    end
  end
end

# Ensure YARD can resolve the provider constant at the top-level
# YARD does something akin to Object.const_get("::" + const), so it expects
# a top-level ::KramdownGfmDocument when const == "KramdownGfmDocument".
# Provide an alias to our namespaced implementation.
# :nocov:
unless defined?(KramdownGfmDocument)
  KramdownGfmDocument = Yard::Fence::KramdownGfmDocument
end
# :nocov:
