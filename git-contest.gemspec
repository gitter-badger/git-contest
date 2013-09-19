# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git/contest/version'

Gem::Specification.new do |spec|
  spec.name          = "git-contest"
  spec.version       = Git::Contest::VERSION
  spec.authors       = ["Hiroyuki Sano"]
  spec.email         = ["sh19910711@gmail.com"]
  spec.description   = %q{git extension for programming contest (Codeforces, Google Codejam, ICPC, etc...)}
  spec.summary       = %q{git extension for programming contest}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "yaml"
  spec.add_development_dependency "bundler", "~> 1.4"
  spec.add_development_dependency "rake"
end
