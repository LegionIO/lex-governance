# frozen_string_literal: true

require 'bundler/setup'

module Legion
  module Logging
    def self.debug(_msg); end

    def self.info(_msg); end

    def self.warn(_msg); end

    def self.error(_msg); end
  end

  module Extensions
    module Core; end
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
