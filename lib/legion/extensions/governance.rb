# frozen_string_literal: true

require 'legion/extensions/governance/version'
require 'legion/extensions/governance/helpers/layers'
require 'legion/extensions/governance/helpers/proposal'
require 'legion/extensions/governance/runners/governance'

module Legion
  module Extensions
    module Governance
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
