require 'rspec'
require 'nokogiri'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end

RSpec::Matchers.define :render_html do |html|
  diffable

  match do |markdown|
    parser = Redcarpet::Markdown.new(described_class)
    rendered = parser.render(markdown)

    @actual = Nokogiri::XML(rendered, &:noblanks).to_xhtml(indent: 2)
    @expected = Nokogiri::XML(expected, &:noblanks).to_xhtml(indent: 2)

    @expected == @actual
  end
end
