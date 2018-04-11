require "rspec"

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

    instance = Middleman::HashiCorp::RedcarpetHTML.new()

    options = Middleman::HashiCorp::RedcarpetHTML::REDCARPET_OPTIONS
    parser = Redcarpet::Markdown.new(instance, options)

    #logger = Logger.new(STDOUT)
    #logger.debug("Parser: #{parser.methods}")

    @actual = parser.render(markdown).strip

    @expected == @actual
  end
end

# The default middleman application server.
#
# @return [Middleman::Application]
def middleman_app
  @app ||= Middleman::Application.new()
end
