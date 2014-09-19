# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "sinatra-index"
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eli Fox-Epstein"]
  s.date = "2011-01-11"
  s.description = "Provides indices for public"
  s.email = ["eli@redhyphen.com"]
  s.homepage = "http://github.com/elitheeli/sinatra-index"
  s.require_paths = ["lib"]
  s.rubyforge_project = "sinatra-index"
  s.rubygems_version = "2.0.14"
  s.summary = "Provides indices for public"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sinatra>, [">= 0"])
    else
      s.add_dependency(%q<sinatra>, [">= 0"])
    end
  else
    s.add_dependency(%q<sinatra>, [">= 0"])
  end
end
