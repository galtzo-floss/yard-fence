# frozen_string_literal: true

# Prepare sanitized copies of Markdown/TXT files in tmp/yard-fence/ for YARD consumption.
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
# Strategy (tmp/yard-fence/ preprocessor)
# - At doc build time, copy top-level *.md/*.txt into tmp/yard-fence/ and transform only the risky
#   brace pairs in contexts YARD misinterprets:
#   * inside triple‑backtick fenced code blocks
#   * inside single‑backtick inline code spans
#   * simple brace placeholders in prose like ｛issuer｝ or ｛｛TEMPLATE｝｝
# - The transformation uses Unicode "fullwidth" braces: ｛ and ｝.
#   These look like normal ASCII braces when rendered, but importantly they do not match
#   YARD's `{…}` reference tag regex, so they are ignored by the link resolver.
# - After YARD finishes generating HTML into docs/, we post‑process the HTML and convert
#   fullwidth braces back to ASCII braces so copying code from the docs works as expected.
#
# Key lines to see:
# - Transform to fullwidth:   str.tr('{}', '｛｝')
#   This replaces ASCII { and } with their fullwidth Unicode counterparts in sanitized tmp/yard-fence files.
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
begin
  require_relative "fence/kramdown_gfm_document"
# :nocov:
# Not covering, because kramdown support is tested, so this rescue is not hit in test runs.
rescue LoadError => error
  # check the error message, and re-raise if not what is expected
  if error.message.include?("kramdown")
    warn("Yard::Fence: Kramdown GFM provider not loaded: #{error.class}: #{error.message}") if ENV.fetch("YARD_DEBUG", "false").casecmp?("true")
  else
    raise error
  end
end
# :nocov:

module Yard
  module Fence
    ASCII_BRACES = "{}"
    FULLWIDTH_BRACES = "｛｝"
    # IMPORTANT: YARD expects :const to be a String.
    # YARD concatenates with a String prefix (e.g., "::" + const),
    # so a Symbol here will break provider resolution. Some static analyzers
    # suggest making this a Symbol to match types, but that is incorrect for YARD.
    # Do NOT change this to a Symbol.
    KRAMDOWN_PROVIDER = {lib: :kramdown, const: "KramdownGfmDocument"}
    GLOB_PATTERN = "*.{md,MD,txt,TXT}"
    TRIPLE_TICK_FENCE = /^\s*```/
    INLINE_TICK_FENCE = /`([^`]+)`/
    DOUBLE_BRACE_PLACEHOLDER_REGEX = /{{([^{}]+)}}/
    SINGLE_BRACE_PLACEHOLDER_REGEX = /{([A-Za-z0-9_:\-]+)}/
    # Lines that are part of a classic indented code block (CommonMark: 4 spaces)
    INDENTED_CODE_LINE = /^ {4,}\S/

    class Error < StandardError; end
    # :nocov:
    # This is a runtime sanity check to ensure our fullwidth braces differ from ASCII braces.
    raise Error, "ASCII braces are not the same as Unicode Fullwidth braces" if ASCII_BRACES == FULLWIDTH_BRACES
    # :nocov:

    module_function

    # Replace ASCII { } with Unicode fullwidth ｛ ｝.
    # Visual effect in browsers is the same, but YARD's link matcher won't recognize them.
    def fullwidth_braces(str)
      str.tr(ASCII_BRACES, FULLWIDTH_BRACES)
    end

    # Escape braces inside inline `code` spans only.
    def sanitize_inline_code(line)
      # Use Regexp.last_match to safely access capture; to_s guards against nil
      line.gsub(INLINE_TICK_FENCE) do |_|
        inner = Regexp.last_match(1).to_s
        "`#{fullwidth_braces(inner)}`"
      end
    end

    # Walk the text, toggling a simple in_fence state on ``` lines.
    # While inside a fence, convert braces to fullwidth; outside, also sanitize inline code
    # and disarm simple prose placeholders like ｛issuer｝ or ｛｛something｝｝.
    def sanitize_fenced_blocks(text)
      in_fence = false
      in_indented_block = false

      text.each_line.map do |line|
        if line.match?(TRIPLE_TICK_FENCE)
          # Toggle fenced block state; leaving indented block if switching into explicit fence
          in_fence = !in_fence
          in_indented_block = false if in_fence
          line
        elsif in_fence
          fullwidth_braces(line)
        elsif in_indented_block
          # Continue indented block until a blank line or non-indented line breaks it
          if line.strip.empty? || !line.match?(INDENTED_CODE_LINE)
            in_indented_block = false
            # Process this line as normal prose outside block
            ln = sanitize_inline_code(line)
            ln = ln.gsub(DOUBLE_BRACE_PLACEHOLDER_REGEX) { |m| fullwidth_braces(m) }
            ln.gsub(SINGLE_BRACE_PLACEHOLDER_REGEX) { |m| fullwidth_braces(m) }
          else
            fullwidth_braces(line)
          end
        elsif line.match?(INDENTED_CODE_LINE)
          # Enter indented code block on first qualifying line
          in_indented_block = true
          fullwidth_braces(line)
        else
          ln = sanitize_inline_code(line)
          # IMPORTANT: handle double-brace placeholders first so we don't partially
          # convert the inner {TOKEN} and leave outer ASCII braces from `{｛TOKEN｝}`.
          ln = ln.gsub(DOUBLE_BRACE_PLACEHOLDER_REGEX) { |m| fullwidth_braces(m) }
          ln.gsub(SINGLE_BRACE_PLACEHOLDER_REGEX) { |m| fullwidth_braces(m) }
        end
      end.join
    end

    def sanitize_text(text)
      return text unless text.is_a?(String)
      sanitize_fenced_blocks(text)
    end

    # Copy top-level *.md/*.txt into tmp/yard-fence/ with the above sanitization applied.
    def prepare_tmp_files
      root = Dir.pwd
      outdir = File.join(root, "tmp", "yard-fence")
      FileUtils.mkdir_p(outdir)

      candidates = Dir.glob(File.join(root, GLOB_PATTERN))
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
      if ENV.fetch("YARD_FENCE_DISABLE", "false").casecmp?("true")
        warn("[yard/fence] postprocess_html_docs disabled via YARD_FENCE_DISABLE")
      else
        docs = File.join(Dir.pwd, "docs")
        return unless Dir.exist?(docs)
        Dir.glob(File.join(docs, "**", "*.html")).each do |html|
          restore_ascii_braces_in_html_file(html)
        end
      end
    rescue => e
      warn("Yard::Fence.postprocess_html_docs failed: #{e.class}: #{e.message}")
    end

    # Register Kramdown GFM as the highest priority Markdown provider in YARD.
    # Returns true if registration succeeded, false otherwise.
    #
    # This method is intentionally not executed at file load to avoid circular
    # require warnings when YARD is in the middle of loading itself. Call this
    # from a file loaded via .yardopts (e.g. `-e 'require "yard/fence/kramdown_gfm"; Yard::Fence.use_kramdown_gfm!'`).
    def use_kramdown_gfm!
      # :nocov:
      # Not covering, because kramdown support is tested, so this rescue is not hit in test runs.
      unless defined?(Yard::Fence::KramdownGfmDocument)
        raise Error, "Yard::Fence: Kramdown GFM provider not loaded. Add kramdown and kramdown-parser-gfm to your Gemfile."
      end
      # :nocov:
      providers = ::YARD::Templates::Helpers::MarkupHelper::MARKUP_PROVIDERS[:markdown]
      # NOTE: Intentionally using String for :const in KRAMDOWN_PROVIDER.
      # YARD performs string concatenation with this value (e.g., "::" + const).
      # Changing it to a Symbol to satisfy static type hints breaks runtime behavior.
      # Suppress type fuzz complaints: expected Hash{Symbol->Symbol}, actual includes String by design.
      providers.unshift(KRAMDOWN_PROVIDER)
      providers.uniq! { |p| [p[:lib].to_s, p[:const].to_s] }
      true
    rescue NameError => e
      warn("Yard::Fence.use_kramdown_gfm!: failed to load YARD helper: #{e.class}: #{e.message}")
      false
    end

    def at_load_hook
      if ENV.fetch("YARD_FENCE_DISABLE", "false").casecmp?("true")
        warn("[yard/fence] at_load_hook disabled via YARD_FENCE_DISABLE")
      else
        Yard::Fence.prepare_tmp_files
      end
    rescue => e
      warn("Yard::Fence: failed to prepare tmp/yard-fence files: #{e.class}: #{e.message}")
    end
  end

  # Execute at load-time so files exist before YARD scans tmp/yard-fence/*.md
  Yard::Fence.at_load_hook
end

# Extend the Version with VersionGem::Basic to provide semantic version helpers.
Yard::Fence::Version.class_eval do
  extend VersionGem::Basic
end

# :nocov:
# Not checking coverage of the at_exit hook, because it would require a forked process.
unless ENV["YARD_FENCE_SKIP_AT_EXIT"] == "1"
  # After YARD completes, restore ASCII braces in generated HTML docs.
  # This guarantees the published docs (docs/*.html) show and copy normal { }.
  at_exit do
    Yard::Fence.postprocess_html_docs
  end
end
# :nocov:
