require "open-uri"

class Middleman::HashiCorp::Releases
  RELEASES_URL = "https://releases.hashicorp.com".freeze

  class Build < Struct.new(:name, :version, :os, :arch, :url); end

  def self.fetch(product, version)
    url = "#{RELEASES_URL}/#{product}/#{version}/index.json"
    r = JSON.parse(open(url).string,
      create_additions: false,
      symbolize_names: true,
    )

    # Convert the builds into the following format:
    #
    #     {
    #       "os" => {
    #         "arch" => "https://download.url"
    #       }
    #     }
    #
    {}.tap do |h|
      r[:builds].each do |b|
        build = Build.new(*b.values_at(*Build.members))

        h[build.os] ||= {}
        h[build.os][build.arch] = build.url
      end
    end
  end
end
