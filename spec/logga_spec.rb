# frozen_string_literal: true

RSpec.describe Logga do
  describe "VERSION" do
    let(:current_version) { File.read("VERSION").split("\n").first }

    it "is set from the VERSION file" do
      expect(::Logga::VERSION).to eq(current_version)
    end
  end
end
