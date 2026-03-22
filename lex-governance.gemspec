# frozen_string_literal: true

require_relative 'lib/legion/extensions/governance/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-governance'
  spec.version       = Legion::Extensions::Governance::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX::Governance'
  spec.description   = 'AIRB compliance gates and governance policy enforcement for LegionIO'
  spec.homepage      = 'https://github.com/LegionIO'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*']
  spec.require_paths = ['lib']
end
