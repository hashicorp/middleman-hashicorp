module Middleman
  module HashiCorp
    require_relative "bintray"
    require_relative "redcarpet"
    require_relative "releases"
    require_relative "rouge"
  end
end

class Middleman::HashiCorpExtension < ::Middleman::Extension
  option :bintray_enabled, false, "Whether Bintray is enabeld"
  option :bintray_repo, nil, "The Bintray repo name (e.g. mitchellh/packer)"
  option :bintray_user, nil, "The Bintray http basic auth user (e.g. mitchellh)"
  option :bintray_key, nil, "The Bintray http basic auth key (e.g. abcd1234)"
  option :bintray_exclude_proc, nil, "A filter to apply for packages"
  option :bintray_prefixed, true, "Whether packages are prefixed with the project name"

  option :name, nil, "The name of the package (e.g. 'consul')"
  option :version, nil, "The version of the package (e.g. 0.1.0)"
  option :minify_javascript, true, "Whether to minimize JS or not"
  option :github_slug, nil, "The project's GitHub namespace/project_name duo (e.g. hashicorp/serf)"
  option :website_root, "website", "The project's middleman directory relative to the Git root"
  option :releases_enabled, true, "Whether to fetch releases"

  def initialize(app, options_hash = {}, &block)
    super

    # Grab a reference to self so we can access it deep inside blocks
    _self = self

    # Use syntax highlighting on fenced code blocks
    # This is super hacky, but middleman does not let you activate an
    # extension on "app" outside of the "configure" block.
    require "middleman-syntax"
    syntax = Proc.new { activate :syntax }
    app.configure(:development, &syntax)
    app.configure(:build, &syntax)

    # Organize assets like Rails
    app.set :css_dir,    "assets/stylesheets"
    app.set :js_dir,     "assets/javascripts"
    app.set :images_dir, "assets/images"
    app.set :fonts_dir,  "assets/fonts"

    # Make custom assets available
    assets = Proc.new { sprockets.import_asset "ie-compat.js" }
    app.configure(:development, &assets)
    app.configure(:build, &assets)

    # Override the default Markdown settings to use our customer renderer
    # and the options we want!
    app.set :markdown_engine, :redcarpet
    app.set :markdown, Middleman::HashiCorp::RedcarpetHTML::REDCARPET_OPTIONS.merge(
      renderer: Middleman::HashiCorp::RedcarpetHTML
    )

    # Set the latest version
    app.set :latest_version, options.version

    # Do the releases dance
    app.set :product_versions, _self.product_versions

    app.set :github_slug, options.github_slug
    app.set :website_root, options.website_root

    # Configure the development-specific environment
    app.configure :development do
      # Reload the browser automatically whenever files change
      require "middleman-livereload"
      activate :livereload,
        host: "0.0.0.0"
    end

    # Configure the build-specific environment
    minify_javascript = options.minify_javascript
    app.configure :build do
      # Minify CSS on build
      activate :minify_css

      if minify_javascript
        # Minify Javascript on build
        activate :minify_javascript
      end

      # Enable cache buster
      activate :asset_hash
    end
  end

  helpers do
    #
    # Output an image that corresponds to the given operating system using the
    # vendored image icons.
    #
    # @return [String] (html)
    #
    def system_icon(name)
      image_tag("icons/icon_#{name.to_s.downcase}.png")
    end

    #
    # The formatted operating system name.
    #
    # @return [String]
    #
    def pretty_os(os)
      case os
      when /darwin/
        "Mac OS X"
      when /freebsd/
        "FreeBSD"
      when /openbsd/
        "OpenBSD"
      when /netbsd/
        "NetBSD"
      when /linux/
        "Linux"
      when /windows/
        "Windows"
      else
        os.capitalize
      end
    end

    #
    # The formatted architecture name.
    #
    # @return [String]
    #
    def pretty_arch(arch)
      case arch
      when /all/
        "Universal (32 and 64-bit)"
      when /686/, /386/
        "32-bit"
      when /86_64/, /amd64/
        "64-bit"
      else
        parts = arch.split("_")

        if parts.empty?
          raise "Could not determine pretty arch `#{arch}'!"
        end

        parts.last.capitalize
      end
    end

    #
    # Calculate the architecture for the given filename (from Bintray).
    #
    # @return [String]
    #
    def arch_for_filename(path)
      file = File.basename(path, File.extname(path))

      case file
      when /686/, /386/
        "32-bit"
      when /86_64/, /amd64/
        "64-bit"
      else
        parts = file.split("_")

        if parts.empty?
          raise "Could not determine arch for filename `#{file}'!"
        end

        parts.last.capitalize
      end
    end

    #
    # Return the GitHub URL associated with the project
    # @return [String] the project's URL on GitHub
    # @return [false] if github_slug hasn't been set
    #
    def github_url(specificity = :repo)
      return false if github_slug.nil?
      base_url = "https://github.com/#{github_slug}"
      if specificity == :repo
        base_url
      elsif specificity == :current_page
        base_url + "/blob/master/" + path_in_repository(current_page)
      end
    end

    #
    # Return a resource's path relative to its source repo's root directory.
    # @param page [Middleman::Sitemap::Resource] a sitemap resource object
    # @return [String] a resource's path relative to its source repo's root
    # directory
    #
    def path_in_repository(resource)
      relative_path = resource.path.match(/.*\//).to_s
      file = resource.source_file.split("/").last
      website_root + "/source/" + relative_path + file
    end
  end

  #
  # Query the Bintray API to get the real product download versions.
  #
  # @return [Hash]
  #
  def product_versions
    if !options.bintray_enabled && !options.releases_enabled
      return {
        "HashiOS" => {
          "amd64" => "/0.1.0_hashios_amd64.zip",
          "i386" => "/0.1.0_hashios_i386.zip",
        }
      }
    end

    if options.bintray_repo
      Middleman::HashiCorp::BintrayAPI.new(
        repo:     options.bintray_repo,
        user:     options.bintray_user,
        key:      options.bintray_key,
        filter:   options.bintray_exclude_proc,
        prefixed: options.bintray_prefixed,
      ).downloads_for_version(options.version)
    else
      Middleman::HashiCorp::Releases.fetch(options.name, options.version)
    end
  end
end
