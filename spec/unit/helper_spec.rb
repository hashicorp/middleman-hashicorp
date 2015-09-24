require 'spec_helper'
require 'middleman-hashicorp/hashicorp'

class Middleman::HashiCorpExtension
  describe 'page_source helper' do
    app = middleman_app
    instance = Middleman::HashiCorpExtension.new(app, bintray_enabled: false)
    instance.app = app # unclear why this needs to be set after, but it must

    it 'returns path/filename.extension for non-index files' do
      current_page = Middleman::Sitemap::Resource.new(
        app.sitemap,
        '/foo/security.html',
        '/some/series/of/directories/website/source/security.html.erb')
      page_source = instance.app.github_path(current_page)
      expect(page_source).to eql('blob/master/website/source/security.html.erb')
    end
  end
end
