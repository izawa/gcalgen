# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gcalgen/version'

Gem::Specification.new do |spec|
  spec.name          = "gcalgen"
  spec.version       = Gcalgen::VERSION
  spec.authors       = ["Yukimitsu Izawa"]
  spec.email         = ["izawa@izawa.org"]
  spec.description   = %q{Google Calendar event generator}
  spec.summary       = %q{Google Calendar event generator}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
