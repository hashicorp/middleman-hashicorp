require "spec_helper"
require "middleman-hashicorp/extension"

class Middleman::HashiCorpExtension
  describe "#github_url" do
    before(:all) do
      app = middleman_app
      @instance = Middleman::HashiCorpExtension.new(
        app,
        bintray_enabled: false,
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
        bintray_enabled: false,
      )
      slugless_instance.app = slugless_app
      expect(slugless_instance.app.github_url).to eq(false)
    end
  end

  describe "#path_in_repository" do
    before(:each) do
      app = middleman_app
      @instance = Middleman::HashiCorpExtension.new(
        app,
        bintray_enabled: false,
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
end
