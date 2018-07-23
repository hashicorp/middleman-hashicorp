require "json"
require "open-uri"
require "net/http"

class Middleman::HashiCorp::LatestRelease

  def self.fetch(product)
    url = "https://releases.hashicorp.com/#{product}/index.json"
    req = open(url)
    body = req.read

    r = JSON.parse(body,
      create_additions: false,
      symbolize_names: true,
    )

    versions = []
    r[:versions].each do |ver|
      v = Hash[ver[1]]
      version = v[:version]
      versions << version
    end

    sortedVersions = versions.sort_by(&Gem::Version.method(:new))
    puts sortedVersions.last
  end

end
