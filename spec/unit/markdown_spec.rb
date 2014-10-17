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

    it 'supports markdown inside HTML', :focus do
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

    # it "supports definition lists" do
    #   markdown = <<-EOH.gsub(/^ {8}/, '')
    #     Some Method
    #     : This is the description

    #     Another Method
    #     : This is more description
    #   EOH
    #   output = <<-EOH.gsub(/^ {8}/, '')
    #     <dl>
    #       <dt>Some Method<dt>
    #       <dd>This is the description</dd>
    #     </dl>
    #     <dl>
    #       <dt>Another Method<dt>
    #       <dd>This is more description</dd>
    #     </dl>
    #   EOH

    #   expect(markdown).to render_html(output)
    # end
  end
end
