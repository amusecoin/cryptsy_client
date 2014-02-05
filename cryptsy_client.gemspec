# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cryptsy_client/version"

Gem::Specification.new do |s|
  s.name        = "cryptsy_client"
  s.version     = CryptsyClient::VERSION
  s.authors     = ["Kimmo Lehto"]
  s.email       = ["kimmo.lehto@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{OO wrapper for cryptsy-api}
  s.description = %q{Object oriented wrapper for the cryptsy crypto currency exchange API}

  s.rubyforge_project = "cryptsy_client"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "cryptsy-api"
end
