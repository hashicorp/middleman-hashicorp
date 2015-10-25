require "spec_helper"
require "middleman-hashicorp/releases"

describe Middleman::HashiCorp::Releases do
  context "when the product does not exist" do
    it "returns an error" do
      expect {
        described_class.fetch("nope", "")
      }.to raise_error(OpenURI::HTTPError)
    end
  end

  context "when the version does not exist" do
    it "returns an error" do
      expect {
        described_class.fetch("vagrant", "0.0.0")
      }.to raise_error(OpenURI::HTTPError)
    end
  end

  it "returns the JSON representation of the version" do
    r = described_class.fetch("consul", "0.1.0")
    expect(r["darwin"]).to eq(
      "amd64" => "https://releases.hashicorp.com/consul/0.1.0/consul_0.1.0_darwin_amd64.zip",
    )
    expect(r["linux"]).to eq(
      "386" => "https://releases.hashicorp.com/consul/0.1.0/consul_0.1.0_linux_386.zip",
      "amd64" => "https://releases.hashicorp.com/consul/0.1.0/consul_0.1.0_linux_amd64.zip",
    )
    expect(r["windows"]).to eq(
      "386" => "https://releases.hashicorp.com/consul/0.1.0/consul_0.1.0_windows_386.zip",
    )
  end
end
