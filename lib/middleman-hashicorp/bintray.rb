require "open-uri"

class Middleman::HashiCorp::BintrayAPI
  OS_TO_HUMAN_MAP = {
    "darwin"  => "Mac OS X",
    "freebsd" => "FreeBSD",
    "openbsd" => "OpenBSD",
    "linux"   => "Linux",
    "windows" => "Windows",
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
  #   api.downloads_for_version("1.0.0") #=>
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
      project = repo.split("/", 2).last
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
          next if filename.include?("SHA256SUMS")

          os = filename.strip.split("_")[-2].strip

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
