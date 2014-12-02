# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'recon/version'

Gem::Specification.new do |spec|
  spec.name          = "recon"
  spec.version       = Recon::VERSION
  spec.authors       = ["Mateusz Czarnecki"]
  spec.email         = ["mateusz.czarnecki92@gmail.com"]
  spec.summary       = %q{A tool for analysis and visualization of projects written in Ruby}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "vrlib", ">= 1.0.16"
  spec.add_dependency "gtk2", ">= 2.2.0"
  spec.add_dependency "require_all", ">= 1.3.2"
  spec.add_dependency "ruby_parser", ">= 3.6.3"
  spec.add_dependency "sexp_processor", ">= 4.4.4"
  spec.add_dependency "gruff", ">= 0.5.1"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
