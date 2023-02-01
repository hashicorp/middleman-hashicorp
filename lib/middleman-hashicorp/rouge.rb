# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MIT

require "rouge"
require "rouge/lexers/javascript"

module Rouge
  module Lexers
    class HCL < Ruby
      title "HCL"
      desc "HashiCorp Configuration Language"

      tag "hcl"
      aliases "nomad", "terraform", "tf"
      filenames "*.hcl", "*.nomad", "*.tf"
      mimetypes "application/hcl", "text/plain"
    end
  end
end
