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
          <li>
            <a name="one" />
            <a href="#one"><code>one</code></a>
          </li>
          <li>
            <a name="two" />
            <a href="#two"><code>two</code></a> has some <code>code</code> inside
          </li>
          <li>
            <a name="three_has_and_spaces" />
            <a href="#three_has_and_spaces"><code>three</code></a> has some <code>code</code> inside
          </li>
          <li>
            <code>four</code>
          </li>
        </ul>
      EOH

      expect(markdown).to render_html(output)
    end

    it "supports markdown inside HTML" do
      markdown = <<-EOH.gsub(/^ {8}/, '')
        This is some markdown

        <div class="center">
          **Here** is some _html_ though! ;)
        </div>
      EOH
      output = <<-EOH.gsub(/^ {8}/, '')
        <p>This is some markdown</p>
        <div class="center">
          <strong>Here</strong> is some <em>html</em> though! ;)
        </div>
      EOH

      expect(markdown).to render_html(output)
    end
  end
end
