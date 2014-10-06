require 'middleman-core'

::Middleman::Extensions.register(:hashicorp) do
  require 'middleman-hashicorp/hashicorp'
  ::Middleman::HashiCorpExtension
end
