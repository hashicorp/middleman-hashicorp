require "open-uri"

class Middleman::HashiCorp::BintrayAPI
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
  #       "os"  => {
  #         "arch" => "http://download.url",
  #       }
  #     }
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

    result = {}

    open(url, options) do |file|
      file.readlines.each do |line|
        if line.chomp! =~ regex
          filename = $1

          # Hardcoded filter
          next if filename.include?("SHA256SUMS")

          os = filename.strip.split("_")[-2].strip

          # Custom filter
          next if filter.call(os, filename)

          result[os] ||= {}
          result[os][arch] = "https://dl.bintray.com/#{repo}/#{filename}"
        end
      end
    end

    result
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
