# frozen_string_literal: true

require "anonymous_loader"
require "yard/fence"
RSpec.describe Yard::Fence::Version do
  it_behaves_like "a Version module", described_class

  it "executes the version file for coverage without redefining constants" do
    paths = [
      File.expand_path("../../../lib/yard/fence/version.rb", __dir__),
      File.expand_path("../../../lib/yard/fence/version_gem.rb", __dir__)
    ].select { |path| File.file?(path) }
    anonymous_namespace = AnonymousLoader.load(files: paths)

    expect(anonymous_namespace::Yard::Fence::Version::VERSION).to eq(described_class::VERSION)
  end
end
