# frozen_string_literal: true

RSpec.describe Yard::Fence::KramdownGfmDocument do
  let(:source_text) { "Hello" }

  describe "inheritance" do
    it "is a subclass of Kramdown::Document" do
      doc = described_class.new(source_text)
      expect(doc).to be_a(Kramdown::Document)
    end
  end

  describe "#initialize" do
    it "sets :input => 'GFM' when not provided" do
      doc = described_class.new(source_text)
      expect(doc.options[:input]).to eq("GFM")
    end

    it "does not override an explicit :input option" do
      doc = described_class.new(source_text, input: "markdown")
      expect(doc.options[:input]).to eq("markdown")
    end

    it "preserves other provided options" do
      doc = described_class.new(source_text, input: "markdown", hard_wrap: false)
      expect(doc.options[:hard_wrap]).to be(false)
    end
  end

  describe "GFM parsing features" do
    context "with fenced code blocks" do
      let(:code_md) do
        <<~MD
          ```ruby
          hash = {alpha: 1, beta: 2}
          ```
        MD
      end

      it "renders fenced code block with language class in HTML" do
        html = described_class.new(code_md).to_html
        expect(html).to include("<pre")
        expect(html).to match(/<code[^>]*class="language-ruby"/)
        expect(html).to include("hash = {alpha: 1, beta: 2}")
      end
    end

    context "with GFM pipe tables" do
      let(:table_md) do
        <<~MD
          | Col A | Col B |
          |-------|-------|
          |  1    |  2    |
        MD
      end

      it "renders a table element in HTML" do
        html = described_class.new(table_md).to_html
        expect(html).to include("<table")
        expect(html).to include("<td>1</td>")
        expect(html).to include("<td>2</td>")
      end
    end

    context "when comparison with plain Kramdown (non-GFM) for fenced code" do
      let(:fence_only) { "```ruby\nputs 'hi'\n```" }

      it "auto-selects GFM while plain Kramdown without input may differ" do
        gfm_html = described_class.new(fence_only).to_html
        # Plain Kramdown default 'kramdown' input might still handle fences in newer versions;
        # this assertion focuses on our class guaranteeing language annotation.
        plain_html = Kramdown::Document.new(fence_only).to_html
        expect(gfm_html).to include('class="language-ruby"')
        # Allow plain_html to possibly lack the language class (older versions) but don't fail if present.
        # Ensure our implementation doesn't degrade compared to plain.
        expect(gfm_html.length).to be >= plain_html.length
      end
    end
  end
end
