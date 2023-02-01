# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MIT

require "middleman-core"
require "middleman-core/renderers/redcarpet"
require "nokogiri"
require "active_support/core_ext/module/attribute_accessors"

# Our custom Markdown parser - extends middleman's customer parser so we pick up
# all the magic.
class Middleman::HashiCorp::RedcarpetHTML < ::Middleman::Renderers::MiddlemanRedcarpetHTML
  # Custom RedCarpet options.
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

  def initialize(options = {})
    super(options.merge(REDCARPET_OPTIONS))
  end

  #
  # Override headers to add custom links.
  #
  def header(title, level)
    anchor = anchor_link(title)

    return <<-EOH.gsub(/^ {6}/, "")
      <h#{level} id="#{anchor}">
        <a name="#{anchor}" class="anchor" href="##{anchor}">&raquo;</a>
        #{title}
      </h#{level}>
    EOH
  end

  #
  # Override list_item to automatically add links for documentation
  #
  # @param [String] text
  # @param [String] list_type
  #
  def list_item(text, list_type)
    @anchors ||= {}

    md = text.match(/\A(?:<p>)?(<code>(.+?)<\/code>)/)
    linked = !text.match(/\A(<p>)?<a(.+?)>(.+?)<\/a>\s*?[-:]?/).nil?

    if !md.nil? && !linked
      container, name = md.captures
      anchor = anchor_link(name)

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
      rendered_content = recursive_render(content)
      # If the recursive render did more than simply wrap
      # the content within a paragraph, assume this is valid
      # markdown content and return the result
      if rendered_content != paragraph(content)
        return "<#{open_tag}>\n#{rendered_content}<#{close_tag}>"
      end
    end
    raw
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
  # Generate an anchor link from the generated raw value.
  #
  # @return [String]
  #
  def anchor_link(raw)
    @anchors ||= {}

    name = raw
      .downcase
      .strip
      .gsub(/<\/?[^>]*>/, '') # Strip links
      .gsub(/\W+/, '-')       # Whitespace to -
      .gsub(/\A\-/, '')       # No leading -
      .squeeze('-')           # Collapse --

    i = 0
    link = name
    while @anchors.key?(link) do
      i += 1
      link = "#{name}-#{i}"
    end
    @anchors[link] = true
    return link
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
      "=&gt;" => "success",
      "-&gt;" => "info",
      "~&gt;" => "warning",
      "!&gt;" => "danger",
    }

    regexp = map.map { |k, _| Regexp.escape(k) }.join("|")

    if md = text.match(/^<p>(#{regexp})/)
      key = md.captures[0]
      klass = map[key]
      text.gsub!(/#{Regexp.escape(key)}\s+?/, "")

      return <<-EOH.gsub(/^ {8}/, "")
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
