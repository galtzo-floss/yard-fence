# frozen_string_literal: true

require "tempfile"
require "yard/fence"

RSpec.describe Yard::Fence do
  it "has a version number" do
    expect(described_class::VERSION).not_to be_nil
  end

  it "is loadable via require 'yard-fence'" do
    expect { require "yard-fence" }.not_to raise_error
    expect(defined?(described_class)).to be_truthy
  end

  describe "::sanitize_text" do
    let(:sample) do
      <<~MD
        Normal prose with {placeholder} and {{DOUBLE}} tokens.
        Inline code: `{:key => :value}` and `{{WRAP}}`.

        ```ruby
        expect { mod.module_eval(modified, src_path, 1) }.to raise_error(Yard::Fence::Error, /ASCII braces are not the same/)
        nested = {outer: {inner: {deep: true}}}
        ```

        Outside fence again {another}.
      MD
    end

    it "replaces braces inside fenced code, inline code and placeholders with fullwidth braces" do
      sanitized = described_class.sanitize_text(sample)
      fw_open = "｛"
      fw_close = "｝"
      expect(sanitized).to include(fw_open)
      expect(sanitized).to include(fw_close)
      # All placeholder patterns converted
      expect(sanitized).not_to include("{placeholder}")
      expect(sanitized).not_to include("{{DOUBLE}}")
      expect(sanitized).not_to include("{{WRAP}}")
      expect(sanitized).not_to include("{another}")
      # Inline code braces converted
      expect(sanitized).not_to include("{:key => :value}")
      # Fence code braces converted
      expect(sanitized).not_to include("{alpha: 1, beta: 2}")
      # Fence markers remain
      expect(sanitized).to include("```ruby")
      # Rough count: number of fullwidth opens equals closes
      opens = sanitized.count(fw_open)
      closes = sanitized.count(fw_close)
      expect(opens).to eq(closes)
      expect(opens).to be > 5
    end

    it "does not alter non-brace content" do
      sanitized = described_class.sanitize_text(sample)
      expect(sanitized).to include("Normal prose")
      expect(sanitized).to include("Inline code:")
    end

    it "returns input unchanged when not a String (branch 98[then])" do
      obj = {a: 1}
      expect(described_class.sanitize_text(obj)).to equal(obj)
      expect(described_class.sanitize_text(nil)).to be_nil
    end

    it "handles multi-line braces in a fenced code example (Faraday OAuth2 client)" do
      sample = <<~MD
        ```ruby
        require "faraday"

        client = OAuth2::Client.new(
          id,
          secret,
          site: "https://api.example.com",
          # Pass Faraday connection options to make FlatParamsEncoder the default
          connection_opts: {
            request: {params_encoder: Faraday::FlatParamsEncoder},
          },
        ) do |faraday|
          faraday.request(:url_encoded)
          faraday.adapter(:net_http)
        end
        ```
      MD

      sanitized = described_class.sanitize_text(sample)
      # Extract the content inside the code fence
      inner = sanitized[/```[^\n]*\n(.*?)\n```/m, 1]
      expect(inner).to be_a(String)
      # Inside the fence, all ASCII braces should be replaced with fullwidth braces
      expect(inner).to include("｛").and include("｝")
      expect(inner).not_to include("{")
      expect(inner).not_to include("}")
      # Fence markers preserved
      expect(sanitized).to include("```ruby")
    end

    it "converts braces in 4-space indented code blocks (CommonMark style)" do
      sample = <<~MD
        Here is some indented code:

            hash = {a: {b: 1}}
            more = {c: 2}

        Back to prose with {placeholder}.
      MD

      sanitized = described_class.sanitize_text(sample)
      # The indented lines should have fullwidth braces
      expect(sanitized).to include("hash = ｛a: ｛b: 1｝｝")
      expect(sanitized).to include("more = ｛c: 2｝")
      # The prose placeholder should also be fullwidth-protected
      expect(sanitized).to include("｛placeholder｝")
    end

    it "exits indented block on a non-indented line and sanitizes that line as prose" do
      sample = <<~MD
            code = {a: 1}
            more = {b: 2}
        Outside with {placeholder} and {{DOUBLE}} and inline `{:sym => :val}`.
      MD

      sanitized = described_class.sanitize_text(sample)
      # Indented lines should have fullwidth braces (treated as code)
      expect(sanitized).to include("code = ｛a: 1｝")
      expect(sanitized).to include("more = ｛b: 2｝")

      # The first non-indented line should be treated as prose and sanitized accordingly:
      # - placeholders converted to fullwidth
      # - inline code braces converted inside backticks
      expect(sanitized).to include("Outside with ｛placeholder｝ and ｛｛DOUBLE｝｝ and inline `｛:sym => :val｝`.")

      # Ensure that outside-of-code generic braces (if any) are not blindly converted except placeholders/inline code
      expect(sanitized).not_to include("{:sym => :val}")
      expect(sanitized).not_to include("{{DOUBLE}}")
      expect(sanitized).not_to include("{placeholder}")
    end

    it "converts consecutive indented code lines (coverage for continuation else branch)" do
      sample = <<~MD
            first = {x: 1}
            second = {y: {z: true}}
            third = {arr: [ {a: 1}, {b: 2} ]}
        After indented block {placeholder}.
      MD

      sanitized = described_class.sanitize_text(sample)
      expect(sanitized).to include("first = ｛x: 1｝")
      expect(sanitized).to include("second = ｛y: ｛z: true｝｝")
      expect(sanitized).to include("third = ｛arr: [ ｛a: 1｝, ｛b: 2｝ ]｝")
      # Ensure prose line sanitized
      expect(sanitized).to include("After indented block ｛placeholder｝.")
    end
  end

  describe "::at_load_hook" do
    it "returns nil and does nothing (deprecated)" do
      # at_load_hook is now intentionally empty - all preparation happens via rake task
      expect(described_class.at_load_hook).to be_nil
    end
  end

  describe "::prepare_for_yard" do
    describe "error path" do
      it "rescues and warns if an exception occurs during processing", :check_output do
        # Force the method past the early return and then raise inside the loop
        allow(described_class).to receive(:prepare_tmp_files).and_raise(StandardError, "boom from prepare_tmp_files")

        output = capture(:stderr) { described_class.prepare_for_yard }
        expect(output).to include("Yard::Fence: failed to prepare for YARD: StandardError: boom from prepare_tmp_files")
      end
    end

    it "calls clean_docs_directory and prepare_tmp_files" do
      expect(described_class).to receive(:clean_docs_directory).ordered
      expect(described_class).to receive(:prepare_tmp_files).ordered

      described_class.prepare_for_yard
    end

    it "can be disabled via YARD_FENCE_DISABLE", :check_output do
      stub_env("YARD_FENCE_DISABLE" => "true")

      expect(described_class).not_to receive(:clean_docs_directory)
      expect(described_class).not_to receive(:prepare_tmp_files)

      output = capture(:stderr) { described_class.prepare_for_yard }
      expect(output).to include("[yard/fence] prepare_for_yard disabled via YARD_FENCE_DISABLE")
    end
  end

  describe "::prepare_tmp_files" do
    it "skips non-file candidates matched by the glob (branch 110[then])" do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          Dir.mkdir("examples.md")
          original = "Code: {a: 1}"
          File.write("README.md", original)

          expect(Dir.exist?("tmp")).to be(false)
          described_class.prepare_tmp_files

          expect(File.exist?(File.join("tmp", "yard-fence", "examples.md"))).to be(false)
          out = File.read(File.join("tmp", "yard-fence", "README.md"))
          expect(out).to eq(described_class.sanitize_text(original))
        end
      end
    end

    it "clears existing staging directory before regenerating files" do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          # Create a markdown file
          File.write("README.md", "Hello {world}")

          # First run creates the staging directory
          described_class.prepare_tmp_files
          expect(File.exist?(File.join("tmp", "yard-fence", "README.md"))).to be(true)

          # Manually add a stale file that shouldn't exist
          stale_file = File.join("tmp", "yard-fence", "STALE.md")
          File.write(stale_file, "This should be removed")
          expect(File.exist?(stale_file)).to be(true)

          # Second run should clear the directory, removing the stale file
          described_class.prepare_tmp_files
          expect(File.exist?(stale_file)).to be(false)
          expect(File.exist?(File.join("tmp", "yard-fence", "README.md"))).to be(true)
        end
      end
    end

    it "removes files from staging when source files are deleted" do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          # Create two markdown files
          File.write("README.md", "Hello {world}")
          File.write("CHANGELOG.md", "Changes {here}")

          # First run creates both files in staging
          described_class.prepare_tmp_files
          expect(File.exist?(File.join("tmp", "yard-fence", "README.md"))).to be(true)
          expect(File.exist?(File.join("tmp", "yard-fence", "CHANGELOG.md"))).to be(true)

          # Delete one source file
          File.delete("CHANGELOG.md")

          # Second run should only have README.md
          described_class.prepare_tmp_files
          expect(File.exist?(File.join("tmp", "yard-fence", "README.md"))).to be(true)
          expect(File.exist?(File.join("tmp", "yard-fence", "CHANGELOG.md"))).to be(false)
        end
      end
    end
  end

  describe "::clean_docs_directory" do
    it "does nothing when YARD_FENCE_CLEAN_DOCS is not set" do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          FileUtils.mkdir_p("docs")
          File.write(File.join("docs", "index.html"), "<html></html>")

          hide_env("YARD_FENCE_CLEAN_DOCS")
          described_class.clean_docs_directory

          expect(File.exist?(File.join("docs", "index.html"))).to be(true)
        end
      end
    end

    it "does nothing when YARD_FENCE_CLEAN_DOCS is false" do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          FileUtils.mkdir_p("docs")
          File.write(File.join("docs", "index.html"), "<html></html>")

          stub_env("YARD_FENCE_CLEAN_DOCS" => "false")
          described_class.clean_docs_directory

          expect(File.exist?(File.join("docs", "index.html"))).to be(true)
        end
      end
    end

    it "clears docs directory when YARD_FENCE_CLEAN_DOCS is true" do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          FileUtils.mkdir_p(File.join("docs", "nested"))
          File.write(File.join("docs", "index.html"), "<html></html>")
          File.write(File.join("docs", "nested", "page.html"), "<html></html>")

          stub_env("YARD_FENCE_CLEAN_DOCS" => "true")
          output = capture(:stdout) { described_class.clean_docs_directory }

          expect(Dir.exist?("docs")).to be(false)
          expect(output).to include("Cleared docs/ directory")
        end
      end
    end

    it "does nothing when docs directory does not exist" do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          stub_env("YARD_FENCE_CLEAN_DOCS" => "true")
          expect { described_class.clean_docs_directory }.not_to raise_error
          expect(Dir.exist?("docs")).to be(false)
        end
      end
    end
  end

  describe "::restore_ascii_braces_in_html_file" do
    it "restores fullwidth braces to ASCII in HTML files" do
      Dir.mktmpdir do |dir|
        html_path = File.join(dir, "index.html")
        content = <<~HTML
          <pre><code>hash = ｛alpha: 1, beta: 2｝</code></pre>
          <p>placeholder ｛issuer｝</p>
        HTML
        File.write(html_path, content)

        described_class.restore_ascii_braces_in_html_file(html_path)

        restored = File.read(html_path)
        expect(restored).to include("hash = {alpha: 1, beta: 2}")
        expect(restored).to include("{issuer}")
        expect(restored).to not_include("｛").and not_include("｝")
      end
    end

    it "no-ops when the file does not exist (branch 119[then])" do
      Dir.mktmpdir do |dir|
        missing = File.join(dir, "missing.html")
        expect { described_class.restore_ascii_braces_in_html_file(missing) }.not_to raise_error
        expect(File.exist?(missing)).to be(false)
      end
    end
  end

  describe "::postprocess_html_docs" do
    it "returns early when docs directory is absent (branch 127[then])" do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          expect(Dir.exist?("docs")).to be(false)
          expect { described_class.postprocess_html_docs }.not_to raise_error
        end
      end
    end

    it "processes html files when docs directory exists" do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          FileUtils.mkdir_p(File.join("docs", "nested"))
          html = File.join("docs", "nested", "page.html")
          File.write(html, "<code>｛x: 1｝</code>")

          described_class.postprocess_html_docs

          expect(File.read(html)).to include("{x: 1}")
        end
      end
    end

    describe "error path" do
      it "rescues and warns if an exception occurs during processing", :check_output do
        # Force the method past the early return and then raise inside the loop
        allow(Dir).to receive(:exist?).and_return(true)
        allow(Dir).to receive(:glob).and_raise(StandardError, "boom from glob")

        output = capture(:stderr) { described_class.postprocess_html_docs }
        expect(output).to include("Yard::Fence.postprocess_html_docs failed: StandardError: boom from glob")
      end
    end
  end

  describe "::use_kramdown_gfm!" do
    it "registers kramdown GFM provider at highest priority" do
      success = described_class.use_kramdown_gfm!
      expect(success).to be(true)
      providers = YARD::Templates::Helpers::MarkupHelper::MARKUP_PROVIDERS[:markdown]
      expect(providers.first[:const]).to be_a(String)
      expect(providers.first[:const]).to eq("KramdownGfmDocument")
    end

    it "is idempotent and does not duplicate entries" do
      described_class.use_kramdown_gfm!
      described_class.use_kramdown_gfm!
      providers = YARD::Templates::Helpers::MarkupHelper::MARKUP_PROVIDERS[:markdown]
      count = providers.count { |p| p[:const] == "KramdownGfmDocument" }
      expect(count).to eq(1)
    end

    it "unshifts provider to the front and deduplicates using stringified keys" do
      providers = YARD::Templates::Helpers::MarkupHelper::MARKUP_PROVIDERS[:markdown]
      original = providers.dup
      begin
        # Seed providers with a different engine and two duplicates of our provider
        providers.clear
        providers.push(
          {lib: :redcarpet, const: "Redcarpet"},
          {lib: :kramdown, const: "KramdownGfmDocument"}, # exact match
          {lib: "kramdown", const: :KramdownGfmDocument}, # mixed types; to_s should dedupe
        )

        result = described_class.use_kramdown_gfm!
        expect(result).to be(true)

        # Provider is highest priority
        expect(providers.first[:lib]).to eq(:kramdown)
        expect(providers.first[:const]).to eq("KramdownGfmDocument")

        # Only one kramdown/GFM entry remains after uniq!
        count = providers.count { |p| p[:lib].to_s == "kramdown" && p[:const].to_s == "KramdownGfmDocument" }
        expect(count).to eq(1)

        # Other providers are preserved
        expect(providers.any? { |p| p[:lib] == :redcarpet }).to be(true)
      ensure
        providers.replace(original)
      end
    end

    it "returns true and leaves array unchanged when already prioritized and unique" do
      providers = YARD::Templates::Helpers::MarkupHelper::MARKUP_PROVIDERS[:markdown]
      original = providers.dup
      begin
        # Ensure our provider is already first and unique
        providers.reject! { |p| p[:lib].to_s == "kramdown" && p[:const].to_s == "KramdownGfmDocument" }
        providers.unshift({lib: :kramdown, const: "KramdownGfmDocument"})
        snapshot = providers.dup

        result = described_class.use_kramdown_gfm!
        expect(result).to be(true)
        expect(providers).to eq(snapshot)
        expect(providers.first[:const]).to eq("KramdownGfmDocument")
      ensure
        providers.replace(original)
      end
    end

    describe "error path" do
      it "rescues NameError, warns, and returns false when YARD helper constants are missing", :check_output do
        # Ensure provider is loaded so we reach the NameError spot
        expect(defined?(Yard::Fence::KramdownGfmDocument)).to be_truthy

        # Hide the YARD::Templates constant to trigger NameError when referenced
        hide_const("YARD::Templates")

        result = nil
        output = capture(:stderr) { result = described_class.use_kramdown_gfm! }
        expect(result).to be(false)
        expect(output).to match(/Yard::Fence.use_kramdown_gfm!: failed to load YARD helper: NameError:/)
      end
    end
  end
end
