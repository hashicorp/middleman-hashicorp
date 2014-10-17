require 'rspec'

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
    @expected = html.strip

    parser = Redcarpet::Markdown.new(described_class)
    @actual = parser.render(markdown).strip

    @expected == @actual
  end
end
