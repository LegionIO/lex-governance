# frozen_string_literal: true

require 'bundler/setup'
require 'legion/logging'
require 'legion/settings'
require 'legion/cache/helper'
require 'legion/crypt/helper'
require 'legion/data/helper'
require 'legion/json/helper'
require 'legion/transport/helper'

module Legion
  module Extensions
    module Helpers
      module Lex
        include Legion::Logging::Helper
        include Legion::Settings::Helper
        include Legion::Cache::Helper
        include Legion::Crypt::Helper
        include Legion::Data::Helper
        include Legion::JSON::Helper
        include Legion::Transport::Helper
      end
    end

    module Actors
      class Every
        include Helpers::Lex
      end

      class Once
        include Helpers::Lex
      end
    end
  end

  module Settings
    @store = {}

    class << self
      def [](key)
        @store[key.to_sym] ||= {}
      end

      def []=(key, val)
        @store[key.to_sym] = val
      end

      def dig(*keys)
        keys.reduce(@store) do |obj, k|
          break nil unless obj.is_a?(Hash)

          obj[k.to_sym] || obj[k.to_s]
        end
      end

      def reset!
        @store = {}
      end
    end
  end
end

require 'legion/extensions/governance'
require 'legion/extensions/governance/helpers/airb'
require 'legion/extensions/governance/helpers/authority'
require 'legion/extensions/governance/runners/governance'
require 'legion/extensions/governance/helpers/council'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end
