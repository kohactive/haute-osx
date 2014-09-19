# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sinatra-index/version"

Gem::Specification.new do |s|
  s.name        = "sinatra-index"
  s.version     = Sinatra::Index::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Eli Fox-Epstein']
  s.email       = ['eli@redhyphen.com']
  s.homepage    = "http://github.com/elitheeli/sinatra-index"
  s.summary     = %q{Provides indices for public}
  s.description = %q{Provides indices for public}

  s.rubyforge_project = "sinatra-index"
  
  s.add_dependency 'sinatra'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
