# frozen_string_literal: true

require "tempfile"

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

          expect(File.exist?(File.join("tmp", "examples.md"))).to be(false)
          out = File.read(File.join("tmp", "README.md"))
          expect(out).to eq(described_class.sanitize_text(original))
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
  end
end
