# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gitback/version"

Gem::Specification.new do |s|
  s.name      = "gitback"
  s.version   = Gitback::VERSION
  s.platform  = Gem::Platform::RUBY
  s.authors   = ["Bryce Thornton"]
  s.email     = ["brycethornton@gmail.com"]
  s.homepage  = "http://github.com/brycethornton/gitback"
  s.summary = %q{A simple ruby library for backing up files to git}
  s.description = %q{Provide a list of files and/or directories and gitback will copy them to your git repo, commit and push when there are changes.}

  s.add_dependency "grit", ">= 2.4.1"

  s.rubyforge_project = "gitback"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

