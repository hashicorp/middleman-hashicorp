# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MIT

require "middleman-core"

::Middleman::Extensions.register(:hashicorp) do
  require "middleman-hashicorp/extension"
  ::Middleman::HashiCorpExtension
end
