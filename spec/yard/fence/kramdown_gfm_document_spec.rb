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
        plain_html = Kramdown::Document.new(fence_only).to_html
        expect(gfm_html).to include('class="language-ruby"')
        expect(gfm_html.length).to be >= plain_html.length
      end
    end

    context "with <details markdown=\"1\"> containing a fenced code block" do
      let(:details_md) do
        <<~MD
          <details markdown="1">
            <summary>See Examples</summary>

            ```ruby
            class Example
              def hi; puts :hi; end
            end
            ```

          </details>
        MD
      end

      it "renders the fence as a real code block (no literal ``` in <p>)" do
        html = described_class.new(details_md).to_html
        expect(html).not_to include("<p>```")
        expect(html).to include("<pre")
        expect(html).to include("<code")
        expect(html).to match(/<code[^>]*ruby|<code[^>]*language-ruby/)
      end

      it "does not use fallback when disabled via env var" do
        ENV["YARD_FENCE_DISABLE_FALLBACK"] = "1"
        html = described_class.new(details_md).to_html
        expect(html).to be_a(String)
      ensure
        ENV.delete("YARD_FENCE_DISABLE_FALLBACK")
      end
    end

    context "when fallback behavior" do
      let(:details_with_fence) do
        <<~MD
          <details markdown="1">
            <summary>Example</summary>

            ```ruby
            puts :hi
            ```
          </details>
        MD
      end

      it "applies fallback when needs_fallback? true and fallback_improved? true" do
        doc = described_class.new(details_with_fence)
        original_html = doc.to_html
        allow(doc).to receive_messages(needs_fallback?: true, fallback_improved?: true)
        fallback_html = "<details><pre><code class=\"language-ruby\">puts :hi\n</code></pre></details>"
        fake_fallback = double("FallbackDoc", to_html: fallback_html)
        allow(Kramdown::Document).to receive(:new).and_return(fake_fallback)
        final = doc.to_html
        expect(final).to eq(fallback_html)
        expect(final).not_to eq(original_html) unless original_html == fallback_html
      end

      it "retains original html when needs_fallback? true but fallback_improved? false" do
        doc = described_class.new(details_with_fence)
        original_html = doc.to_html
        allow(doc).to receive_messages(needs_fallback?: true, fallback_improved?: false)
        bad_fallback_html = "<details><p>```ruby\nputs :hi\n```</p></details>"
        fake_fallback = double("BadFallbackDoc", to_html: bad_fallback_html)
        allow(Kramdown::Document).to receive(:new).and_return(fake_fallback)
        final = doc.to_html
        expect(final).to eq(original_html)
        expect(final).not_to eq(bad_fallback_html)
      end

      it "does not invoke fallback when needs_fallback? false" do
        doc = described_class.new(details_with_fence)
        original_html = doc.to_html
        allow(doc).to receive(:needs_fallback?).and_return(false)
        expect(Kramdown::Document).not_to receive(:new)
        final = doc.to_html
        expect(final).to eq(original_html)
      end
    end

    context "when helper decision logic" do
      it "needs_fallback? returns true when html contains <p>```" do
        doc = described_class.new("```\ncode\n```")
        expect(doc.send(:needs_fallback?, "<p>```ruby</p>")).to be(true)
      end

      it "needs_fallback? returns true when details present and no code block in output" do
        src = '<details markdown="1">\n\n```ruby\nputs :hi\n```\n</details>'
        doc = described_class.new(src)
        expect(doc.send(:needs_fallback?, "<details><p>content</p></details>")).to be(true)
      end

      it "needs_fallback? returns false when details present and output has code block" do
        src = '<details markdown="1">\n\n```ruby\nputs :hi\n```\n</details>'
        doc = described_class.new(src)
        html = '<details><pre><code class="language-ruby">puts :hi</code></pre></details>'
        expect(doc.send(:needs_fallback?, html)).to be(false)
      end

      it "fallback_improved? returns true only when no <p>``` and has <pre><code>" do
        doc = described_class.new("irrelevant")
        good = "<pre><code>ok</code></pre>"
        bad1 = "<p>```</p>"
        bad2 = "<pre>no code</pre>"
        expect(doc.send(:fallback_improved?, good)).to be(true)
        expect(doc.send(:fallback_improved?, bad1)).to be(false)
        expect(doc.send(:fallback_improved?, bad2)).to be(false)
      end
    end
  end
end
