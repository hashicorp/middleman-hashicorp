require 'active_support/core_ext/module/attribute_accessors'
require 'middleman-core'
require 'middleman-core/renderers/redcarpet'

REDCARPET_OPTIONS = {
  autolink:           true,
  fenced_code_blocks: true,
  tables:             true,
  no_intra_emphasis:  true,
  with_toc_data:      true,
  xhtml:              true,
  strikethrough:      true,
  superscript:        true,
}.freeze

module Middleman
  module HashiCorp
    # Our custom Markdown parser - extends middleman's customer parser so we
    # pick up all the magic.
    class RedcarpetHTML < ::Middleman::Renderers::MiddlemanRedcarpetHTML
      #
      # Override list_item to automatically add links for documentation
      #
      # @param [String] text
      # @param [String] list_type
      #
      def list_item(text, list_type)
        md = text.match(/(<code>(.+?)<\/code>)/)
        linked = !text.match(/<a(.+?)>(.+?)<\/a>/).nil?

        if !md.nil? && !linked
          container, name = md.captures
          anchor = anchor_for(name)

          replace = %|<a name="#{anchor}" /><a href="##{anchor}">#{container}</a>|
          text.sub!(container, replace)
        end

        "<li>#{text}</li>\n"
      end

      #
      # Override block_html to support parsing nested markdown blocks.
      #
      # @param [String] raw
      #
      def block_html(raw)
        raw = unindent(raw)

        if md = raw.match(/\<(.+?)\>(.*)\<(\/.+?)\>/m)
          open_tag, content, close_tag = md.captures
          "<#{open_tag}>\n#{recursive_render(unindent(content))}<#{close_tag}>"
        else
          raw
        end
      end

      #
      # Override paragraph to support custom alerts.
      #
      # @param [String] text
      # @return [String]
      #
      def paragraph(text)
        add_alerts("<p>#{text.strip}</p>\n")
      end

      private

      #
      # Remove any special characters from the anchor name.
      #
      # @example
      #   anchor_for("this") #=> "this"
      #   anchor_for("this is cool") #=> "this_is_cool"
      #   anchor_for("this__is__cool!") #=> "this__is__cool_"
      #
      #
      # @param [String] text
      # @return [String]
      #
      def anchor_for(text)
        text.gsub(/[^[:word:]]/, '_').squeeze('_')
      end

      #
      # This is jank, but Redcarpet does not provide a way to access the
      # renderer from inside Redcarpet::Markdown. Since we know who we are, we
      # can cheat a bit.
      #
      # @param [String] markdown
      # @return [String]
      #
      def recursive_render(markdown)
        Redcarpet::Markdown.new(self.class, REDCARPET_OPTIONS).render(markdown)
      end

      #
      # Add alert text to the given markdown.
      #
      # @param [String] text
      # @return [String]
      #
      def add_alerts(text)
        map = {
          '=&gt;' => 'success',
          '-&gt;' => 'info',
          '~&gt;' => 'warning',
          '!&gt;' => 'danger',
        }

        regexp = map.map { |k, _| Regexp.escape(k) }.join('|')

        if md = text.match(/^<p>(#{regexp})/)
          key = md.captures[0]
          klass = map[key]
          text.gsub!(/#{Regexp.escape(key)}\s+?/, '')

          return <<-EOH.gsub(/^ {12}/, '')
            <div class="alert alert-#{klass}" role="alert">
            #{text}</div>
          EOH
        else
          return text
        end
      end

      def unindent(string)
        string.gsub(/^#{string.scan(/^[[:blank:]]+/).min_by { |l| l.length }}/, "")
      end
    end
  end

  class BintrayAPI
    require 'open-uri'

    OS_TO_HUMAN_MAP = {
      'darwin'  => 'Mac OS X',
      'freebsd' => 'FreeBSD',
      'openbsd' => 'OpenBSD',
      'linux'   => 'Linux',
      'windows' => 'Windows',
    }.freeze

    attr_reader :filter
    attr_reader :prefixed

    #
    # @param [String] :repo (e.g. mitchellh/packer)
    # @param [String] :user (e.g. mitchellh/packer)
    # @param [String] :key (e.g. abcd1234)
    # @param [Proc] :filter
    # @param [Boolean] :prefixed
    #
    def initialize(repo: nil, user: nil, key: nil, filter: nil, prefixed: true)
      set_or_raise(:repo, repo)
      set_or_raise(:user, user)
      set_or_raise(:key, key)

      @filter = filter || Proc.new {}
      @prefixed = prefixed
    end

    #
    # Get the structured downloads for the given version and required OSes.
    #
    # @example
    #   api.downloads_for_version('1.0.0') #=>
    #     {
    #       "darwin"  => ["0.1.0_darwin_386.zip", "0.1.0_darwin_amd64.zip"],
    #       "freebsd" => ["0.1.0_freebsd_386.zip", "0.1.0_freebsd_amd64.zip", "0.1.0_freebsd_arm.zip"],
    #       "linux"   => ["0.1.0_linux_386.zip", "0.1.0_linux_amd64.zip", "0.1.0_linux_arm.zip"],
    #       "openbsd" => ["0.1.0_openbsd_386.zip", "0.1.0_openbsd_amd64.zip"],
    #       "windows" => ["0.1.0_windows_386.zip", "0.1.0_windows_amd64.zip"]
    #     },
    #
    # @return [Hash]
    #
    def downloads_for_version(version)
      url = "http://dl.bintray.com/#{repo}/"
      options = { http_basic_authentication: [user, key] }

      if prefixed
        project = repo.split('/', 2).last
        regex = /(#{Regexp.escape(project)}_#{Regexp.escape(version)}_.+?)('|")/
      else
        regex = /(#{Regexp.escape(version)}_.+?)('|")/
      end

      result = Hash.new { |h,k| h[k] = [] }

      open(url, options) do |file|
        file.readlines.each do |line|
          if line.chomp! =~ regex
            filename = $1

            # Hardcoded filter
            next if filename.include?('SHA256SUMS')

            os = filename.strip.split('_')[-2].strip

            # Custom filter
            next if filter.call(os, filename)

            human_os = OS_TO_HUMAN_MAP.fetch(os, os)
            result[human_os].push(
              "https://dl.bintray.com/#{repo}/#{filename}"
            )
          end
        end
      end

      result.values.each(&:sort!)
      Hash[*result.sort.flatten(1)]
    rescue OpenURI::HTTPError
      # Ignore HTTP errors and just have no versions
      return {}
    end

    private

    #
    # Magical method that checks if the value is truly present (i.e. not an
    # empty string), raising an exception if it is not. If the value is present,
    # the named instance variable and attr_reader are defined.
    #
    # @raise [RuntimeError]
    # @return [true]
    #
    def set_or_raise(key, value)
      value = value.to_s.strip

      if value.empty?
        raise "Bintray #{key} was not given!"
      end

      instance_variable_set(:"@#{key}", value)
      self.class.send(:attr_reader, :"#{key}")

      true
    end
  end

  class HashiCorpExtension < ::Middleman::Extension
    option :bintray_enabled, true, 'Whether Bintray is enabeld'
    option :bintray_repo, nil, 'The Bintray repo name (e.g. mitchellh/packer)'
    option :bintray_user, nil, 'The Bintray http basic auth user (e.g. mitchellh)'
    option :bintray_key, nil, 'The Bintray http basic auth key (e.g. abcd1234)'
    option :bintray_exclude_proc, nil, 'A filter to apply for packages'
    option :bintray_prefixed, true, 'Whether packages are prefixed with the project name'
    option :version, nil, 'The version of the package (e.g. 0.1.0)'
    option :minify_javascript, true, 'Whether to minimize JS or not'

    def initialize(app, options_hash = {}, &block)
      super

      # Grab a reference to self so we can access it deep inside blocks
      _self = self

      # Use syntax highlighting on fenced code blocks
      # This is super hacky, but middleman does not let you activate an
      # extension on `app' outside of the `configure' block.
      require 'middleman-syntax'
      syntax = Proc.new { activate :syntax }
      app.configure(:development, &syntax)
      app.configure(:build, &syntax)

      # Organize assets like Rails
      app.set :css_dir,    'assets/stylesheets'
      app.set :js_dir,     'assets/javascripts'
      app.set :images_dir, 'assets/images'
      app.set :fonts_dir,  'assets/fonts'

      # Make custom assets available
      assets = Proc.new { sprockets.import_asset "ie-compat.js" }
      app.configure(:development, &assets)
      app.configure(:build, &assets)

      # Override the default Markdown settings to use our customer renderer
      # and the options we want!
      app.set :markdown_engine, :redcarpet
      app.set :markdown, REDCARPET_OPTIONS.merge(
        renderer: Middleman::HashiCorp::RedcarpetHTML
      )

      # Set the latest version
      app.set :latest_version, options.version

      # Do the bintray dance
      if options.bintray_enabled
        app.set :product_versions, _self.real_product_versions
      else
        app.set :product_versions, _self.fake_product_versions
      end

      # Configure the development-specific environment
      app.configure :development do
        # Reload the browser automatically whenever files change
        require 'middleman-livereload'
        activate :livereload
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

        # Minify HTML
        require 'middleman-minify-html'
        activate :minify_html do |html|
          html.remove_quotes = false
          html.remove_script_attributes = false
          html.remove_multi_spaces = false
          html.remove_http_protocol = false
          html.remove_https_protocol = false
        end

        # Enable cache buster
        activate :asset_hash

        # Gzip files
        activate :gzip
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
      # Calculate the architecture for the given filename (from Bintray).
      #
      # @return [String]
      #
      def arch_for_filename(path)
        file = File.basename(path, File.extname(path))

        case file
        when /686/, /386/
          '32-bit'
        when /86_64/, /amd64/
          '64-bit'
        else
          parts = file.split('_')

          if parts.empty?
            raise "Could not determine arch for filename `#{file}'!"
          end

          parts.last.capitalize
        end
      end

      #
      # Return a page's path on GitHub, relative to its source
      # repo's root directory.
      # @param page [Middleman::Sitemap::Resource] a sitemap resource object
      # @return [String] the page's path on GitHub, relative to the repo's root
      # directory
      #
      def github_path(page)
        match = page.source_file.match(/website.*/)
        if match
          'blob/master/' + match[0]
        else
          ''
        end
      end
    end

    #
    # Pre-defined product versions.
    #
    # @return [Hash]
    #
    def fake_product_versions
      {
        'HashiOS' => [
          '/0.1.0_hashios_amd64.zip',
          '/0.1.0_hashios_i386.zip',
        ]
      }
    end

    #
    # Query the Bintray API to get the real product download versions.
    #
    # @return [Hash]
    #
    def real_product_versions
      BintrayAPI.new(
        repo:     options.bintray_repo,
        user:     options.bintray_user,
        key:      options.bintray_key,
        filter:   options.bintray_exclude_proc,
        prefixed: options.bintray_prefixed,
      ).downloads_for_version(options.version)
    end
  end
end
