# frozen_string_literal: true

RSpec.describe Logga::Config do
  describe "initialize" do
    context "with defaults" do
      let(:config) { described_class.new }

      it { expect(config.enabled).to be(true) }

      it { expect(config.excluded_fields).to eq([]) }

      it { expect(config.excluded_suffixes).to eq([]) }
    end

    context "with values" do
      let(:config) { described_class.new(enabled: false, excluded_fields: [:id], excluded_suffixes: [:_id]) }

      it { expect(config.enabled).to be(false) }

      it { expect(config.excluded_fields).to eq([:id]) }

      it { expect(config.excluded_suffixes).to eq([:_id]) }
    end
  end
end
