require "spec_helper"
require "middleman-hashicorp/extension"

class Middleman::HashiCorpExtension
  describe "#github_url" do
    before(:all) do
      app = middleman_app
      @instance = Middleman::HashiCorpExtension.new(app,
        releases_enabled: false,
        name: "consul",
        version: "0.1.0",
        github_slug: "hashicorp/this_project",
      )
      @instance.app = app # unclear why this needs to be set after, but it must
    end

    it "returns the project's GitHub URL if no argument is supplied" do
      expect(@instance.app.github_url).to match("https://github.com/hashicorp/this_project")
    end

    it "returns false if github_slug has not been set" do
      slugless_app = Middleman::Application.server.inst
      slugless_instance = Middleman::HashiCorpExtension.new(
        slugless_app,
        name: "consul",
        version: "0.1.0",
        releases_enabled: false,
      )
      slugless_instance.app = slugless_app
      expect(slugless_instance.app.github_url).to eq(false)
    end
  end

  describe "#path_in_repository" do
    before(:each) do
      app = middleman_app
      @instance = Middleman::HashiCorpExtension.new(app,
        releases_enabled: false,
        name: "consul",
        version: "0.1.0",
        github_slug: "hashicorp/this_project",
        website_root: "website",
      )
      @instance.app = app
    end

    context "when a resource's path string is not within its source_file string" do
      it "returns a resource's path relative to its source repository's root directory" do
        current_page = Middleman::Sitemap::Resource.new(
          @instance.app.sitemap,
          "intro/examples/cross-provider.html",
          "/some/bunch/of/directories/intro/examples/cross-provider.markdown")
        path_in_repository = @instance.app.path_in_repository(current_page)
        expect(path_in_repository).to match("website/source/intro/examples/cross-provider.markdown")
      end
    end

    context "when a resource's path string lies within its source_file string" do
      it "returns a resource's path relative to its source repository's root directory" do
        current_page = Middleman::Sitemap::Resource.new(
          @instance.app.sitemap,
          "docs/index.html",
          "/some/bunch/of/directories/website/source/docs/index.html.markdown")
        path_in_repository = @instance.app.path_in_repository(current_page)
        expect(path_in_repository).to match("website/source/docs/index.html.markdown")
      end
    end
  end

  describe "#pretty_arch" do
    before(:each) do
      app = middleman_app
      @instance = Middleman::HashiCorpExtension.new(app,
        releases_enabled: false,
      )
      @instance.app = app
    end

    [
      ["all", "Universal (32 and 64-bit)"],
      ["i686", "32-bit"],
      ["686", "32-bit"],
      ["386", "32-bit"],
      ["i386", "32-bit"],
      ["86_64", "64-bit"],
      ["x86_64", "64-bit"],
      ["amd64", "64-bit"],
      ["amd64-lxc", "64-bit (lxc)"],
      ["foo_bar", "Bar"],
    ].each do |i,e|
      it "converts #{i} to #{e}" do
        expect(@instance.app.pretty_arch(i)).to eq(e)
      end
    end
  end

  describe "#pretty_os" do
    before(:each) do
      app = middleman_app
      @instance = Middleman::HashiCorpExtension.new(app,
        releases_enabled: false,
      )
      @instance.app = app
    end

    [
      ["darwin", "macOS"],
      ["freebsd", "FreeBSD"],
      ["openbsd", "OpenBSD"],
      ["netbsd", "NetBSD"],
      ["archlinux", "Arch Linux"],
      ["linux", "Linux"],
      ["windows", "Windows"],
    ].each do |given, expected|
      it "converts #{given} to #{expected}" do
        expect(@instance.app.pretty_os(given)).to eq(expected)
      end
    end

    it "should capitalize unknown OS" do
      expect(@instance.app.pretty_os("hashicorplinux")).to eq("Hashicorplinux")
    end
  end

  describe "#latest_provider_version" do
    before(:each) do
      app = middleman_app
      @instance = Middleman::HashiCorpExtension.new(app,
        releases_enabled: false,
      )
      @instance.app = app
    end

    it "returns the latest provider version for a given provider" do
      expect(@instance.app.latest_provider_version("template")).to match(/\d+\.\d+\.\d+/)
    end
  end
end
