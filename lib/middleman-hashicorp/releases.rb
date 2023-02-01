# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MIT

require "open-uri"

class Middleman::HashiCorp::Releases
  RELEASES_URL = "https://releases.hashicorp.com".freeze

  class Build < Struct.new(:name, :version, :os, :arch, :url); end

  def self.fetch(product, version)
    url = "#{RELEASES_URL}/#{product}/#{version}/index.json"
    r = JSON.parse(open(url).read,
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

  #
  # Gets only the most recently released version data for a given product
  #
  def self.fetch_latest_version(product)
    url = "#{RELEASES_URL}/#{product}/index.json"
    res = JSON.parse(open(url).read,
      create_additions: false,
      symbolize_names: true,
    )
    versions = res[:versions]

    # Releases are formatted as an object rather than an array in the JSON
    # structure, so we need to convert to an array then sort by version to
    # get the latest. We then return all info for that version.
    versions[versions.keys.sort_by(&Gem::Version.method(:new)).last]
  end
end
