# coding: utf-8
$LOAD_PATH << File.expand_path('../opal', __FILE__)
require 'music/version'

Gem::Specification.new do |spec|
  spec.name          = "opal-music"
  spec.version       = Music::VERSION
  spec.authors       = ["Jose Añasco"]
  spec.email         = ["joseanasco1@gmail.com"]

  spec.summary       = %q{create music tunes in the browser}
  spec.description   = %q{notes, beats and sounds}
  spec.homepage      = "http://github.com/merongivian/opal-music"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.files         = `git ls-files`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'opal-browser'
  spec.add_runtime_dependency 'opal'
  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "opal-rspec", "~> 0.5.0"
end
