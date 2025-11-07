# frozen_string_literal: true

# Prepare sanitized copies of Markdown/TXT files in tmp/ for YARD consumption.
#
# Why this exists
# - YARD treats any `{…}` sequence in extra files (like README.md) as a potential link
#   to a code object (its "reference tag" syntax). This scanning happens outside of
#   the Markdown renderer and does not reliably respect fenced code blocks.
# - As a result, normal hash literals in code examples, e.g. {get: :query} or
#   {"Authorization" => "Basic ..."}, trigger lots of `[InvalidLink] Cannot resolve link` warnings.
#
# Our constraints
# - We want to keep the source Markdown clean and readable on GitHub (no HTML entities,
#   no backslash escapes sprinkled throughout examples).
# - We need YARD to stop interpreting code-fenced braces as links.
#
# Strategy (tmp/ preprocessor)
# - At doc build time, copy top-level *.md/*.txt into tmp/ and transform only the risky
#   brace pairs in contexts YARD misinterprets:
#   * inside triple‑backtick fenced code blocks
#   * inside single‑backtick inline code spans
#   * simple brace placeholders in prose like {issuer} or {{TEMPLATE}}
# - The transformation uses Unicode "fullwidth" braces: ｛ and ｝.
#   These look like normal ASCII braces when rendered, but importantly they do not match
#   YARD's `{…}` reference tag regex, so they are ignored by the link resolver.
# - After YARD finishes generating HTML into docs/, we post‑process the HTML and convert
#   fullwidth braces back to ASCII braces so copying code from the docs works as expected.
#
# Key lines to see:
# - Transform to fullwidth:   str.tr('{}', '｛｝')
#   This replaces ASCII { and } with their fullwidth Unicode counterparts in sanitized tmp files.
# - Restore to ASCII (HTML):  out = src.tr('｛｝', '{}')
#   This runs after docs are generated and rewrites the HTML contents back to normal { and }.
#
# This keeps README.md pristine while eliminating YARD InvalidLink noise and ensuring
# the published docs remain copy‑pastable.

# includes modules from stdlib
require "fileutils"

# third party gems
require "version_gem"

# includes gem files
require_relative "fence/version"

# Extend the Version with VersionGem::Basic to provide semantic version helpers.
Fence::Version.class_eval do
  extend VersionGem::Basic
end

module Yard
  module Fence
    ASCII_BRACES = '{}'
    FULLWIDTH_BRACES = '｛｝'

    class Error < StandardError; end
    raise Error, "ASCII braces are not the same as Unicode Fullwidth braces" if ASCII_BRACES == FULLWIDTH_BRACES

    module_function

    # Replace ASCII { } with Unicode fullwidth ｛ ｝.
    # Visual effect in browsers is the same, but YARD's link matcher won't recognize them.
    def fullwidth_braces(str)
      str.tr(ASCII_BRACES, FULLWIDTH_BRACES)
    end

    # Escape braces inside inline `code` spans only.
    def sanitize_inline_code(line)
      line.gsub(/`([^`]+)`/) { |m| "`#{fullwidth_braces($1)}`" }
    end

    # Walk the text, toggling a simple in_fence state on ``` lines.
    # While inside a fence, convert braces to fullwidth; outside, also sanitize inline code
    # and disarm simple prose placeholders like {issuer} or {{something}}.
    def sanitize_fenced_blocks(text)
      in_fence = false
      fence_re = /^\s*```/ # matches ``` optionally preceded by spaces

      text.each_line.map do |line|
        if line.match?(fence_re)
          in_fence = !in_fence
          line
        elsif in_fence
          fullwidth_braces(line)
        else
          ln = sanitize_inline_code(line)
          # Disarm simple placeholders in prose so YARD doesn't attempt to linkify them
          ln = ln.gsub(/\{([A-Za-z0-9_:\-]+)\}/) { |m| fullwidth_braces(m) }
          ln.gsub(/\{\{([^{}]+)\}\}/) { |m| fullwidth_braces(m) }
        end
      end.join
    end

    def sanitize_text(text)
      return text unless text.is_a?(String)
      sanitize_fenced_blocks(text)
    end

    # Copy top-level *.md/*.txt into tmp/ with the above sanitization applied.
    def prepare_tmp_files
      root = Dir.pwd
      outdir = File.join(root, 'tmp')
      FileUtils.mkdir_p(outdir)

      candidates = Dir.glob(File.join(root, '*.{md,MD,txt,TXT}'))
      candidates.each do |src|
        next unless File.file?(src)
        content = File.read(src)
        sanitized = sanitize_text(content)
        dst = File.join(outdir, File.basename(src))
        File.write(dst, sanitized)
      end
    end

    def restore_ascii_braces_in_html_file(html_filepath)
      return unless File.file?(html_filepath)
      content = File.read(html_filepath)
      restored = content.tr(FULLWIDTH_BRACES, ASCII_BRACES)
      File.write(html_filepath, restored)
    end

    def postprocess_html_docs
      docs = File.join(Dir.pwd, 'docs')
      return unless Dir.exist?(docs)
      Dir.glob(File.join(docs, '**', '*.html')).each do |html|
        restore_ascii_braces_in_html_file(html)
      end
    rescue => e
      warn("Yard::Fence.postprocess_html_docs failed: #{e.class}: #{e.message}")
    end
  end

  # Execute at load-time so files exist before YARD scans tmp/*.md
  begin
    Yard::Fence.prepare_tmp_files
    # After the files are prepped, load the Kramdown GFM extension to ensure proper rendering.
    begin
      require_relative "fence/kramdown_gfm"
    rescue LoadError
      # Kramdown GFM extension is optional; proceed if not available.
      # This may work with alternative markdown renderers.
    end
  rescue => e
    warn("Yard::Fence: failed to prepare tmp files: #{e.class}: #{e.message}")
  end
end

# After YARD completes, restore ASCII braces in generated HTML docs.
# This guarantees the published docs (docs/*.html) show and copy normal { }.
at_exit do
  Yard::Fence.postprocess_html_docs
end
