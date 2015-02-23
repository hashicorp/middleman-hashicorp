require 'spec_helper'
require 'middleman-hashicorp/hashicorp'

module Middleman::HashiCorp
  describe RedcarpetHTML do
    it 'adds links to code list elements' do
      markdown = <<-EOH.gsub(/^ {8}/, '')
        This is a list:

        - `one`
        - `two` has some `code` inside
        - `three has ^ and spaces` with text
        - four
      EOH
      output = <<-EOH.gsub(/^ {8}/, '')
        <p>This is a list:</p>

        <ul>
        <li><a name="one" /><a href="#one"><code>one</code></a>
        </li>
        <li><a name="two" /><a href="#two"><code>two</code></a> has some <code>code</code> inside
        </li>
        <li><a name="three_has_and_spaces" /><a href="#three_has_and_spaces"><code>three has ^ and spaces</code></a> with text
        </li>
        <li>four
        </li>
        </ul>
      EOH

      expect(markdown).to render_html(output)
    end

    it 'adds links to code list elements when they have newlines' do
      markdown = <<-EOH.gsub(/^ {8}/, '')
        This is a list:

        - `one`

        - `two` has some `code` inside

        - `three has ^ and spaces` with text

        - four
      EOH
      output = <<-EOH.gsub(/^ {8}/, '')
        <p>This is a list:</p>

        <ul>
        <li><p><a name="one" /><a href="#one"><code>one</code></a></p>
        </li>
        <li><p><a name="two" /><a href="#two"><code>two</code></a> has some <code>code</code> inside</p>
        </li>
        <li><p><a name="three_has_and_spaces" /><a href="#three_has_and_spaces"><code>three has ^ and spaces</code></a> with text</p>
        </li>
        <li><p>four</p>
        </li>
        </ul>
      EOH

      expect(markdown).to render_html(output)
    end

    it 'does not add links if they already exist' do
      markdown = <<-EOH.gsub(/^ {8}/, '')
        - [`/one`](#link_one): Some text
        - [`/two`](#link_two)
        - `three` is a regular auto-link
      EOH
      output = <<-EOH.gsub(/^ {8}/, '')
        <ul>
        <li><a href="#link_one"><code>/one</code></a>: Some text
        </li>
        <li><a href="#link_two"><code>/two</code></a>
        </li>
        <li><a name="three" /><a href="#three"><code>three</code></a> is a regular auto-link
        </li>
        </ul>
      EOH

      expect(markdown).to render_html(output)
    end

    it 'supports markdown inside HTML' do
      markdown = <<-EOH.gsub(/^ {8}/, '')
        This is some markdown

        <div class="center">
          **Here** is some _html_ though! ;)
        </div>
      EOH
      output = <<-EOH.gsub(/^ {8}/, '')
        <p>This is some markdown</p>
        <div class="center">
        <p><strong>Here</strong> is some <em>html</em> though! ;)</p>
        </div>
      EOH

      expect(markdown).to render_html(output)
    end

    it 'uses the proper options for recursive markdown' do
      markdown = <<-EOH.gsub(/^ {8}/, '')
        This is some markdown

        <div class="center">
          **Here** is some _html_ though! ;)

          no_intra_emphasis still applies, as does ~~strikethrough~~.
        </div>
      EOH
      output = <<-EOH.gsub(/^ {8}/, '')
        <p>This is some markdown</p>
        <div class="center">
        <p><strong>Here</strong> is some <em>html</em> though! ;)</p>
        <p>no_intra_emphasis still applies, as does <del>strikethrough</del>.</p>
        </div>
      EOH

      expect(markdown).to render_html(output)
    end

    it 'supports alert boxes' do
      markdown = <<-EOH.gsub(/^ {8}/, '')
        => This is a success note

        -> This is an info note

        ~> This is a _warning_ note

        !> This is a danger note

        And this is a regular paragraph!
      EOH
      output = <<-EOH.gsub(/^ {8}/, '')
        <div class="alert alert-success" role="alert">
        <p>This is a success note</p>
        </div>
        <div class="alert alert-info" role="alert">
        <p>This is an info note</p>
        </div>
        <div class="alert alert-warning" role="alert">
        <p>This is a <em>warning</em> note</p>
        </div>
        <div class="alert alert-danger" role="alert">
        <p>This is a danger note</p>
        </div>
        <p>And this is a regular paragraph!</p>
      EOH

      expect(markdown).to render_html(output)
    end
  end
end
