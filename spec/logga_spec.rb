# frozen_string_literal: true

RSpec.describe Logga do
  describe ".configure" do
    before do
      described_class.configure do |config|
        config.enabled = false
        config.excluded_fields = [:id]
        config.excluded_suffixes = [:_id]
      end
    end

    it { expect(described_class.configuration.enabled).to be(false) }

    it { expect(described_class.configuration.excluded_fields).to eq([:id]) }

    it { expect(described_class.configuration.excluded_suffixes).to eq([:_id]) }
  end

  describe ".enabled?" do
    it { expect(described_class.enabled?).to eq(described_class.configuration.enabled) }
  end

  describe ".enabled=" do
    before do
      # defaults to true
      described_class.enabled = false
    end

    it { expect(described_class.configuration.enabled).to be(false) }
  end

  describe ".version" do
    let(:current_version) { File.read("VERSION").split("\n").first }

    it { expect(described_class.version).to eq(current_version) }
  end
end
