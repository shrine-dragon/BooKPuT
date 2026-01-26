# -*- encoding: utf-8 -*-
# stub: omniauth-oauth 1.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "omniauth-oauth".freeze
  s.version = "1.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Bleigh".freeze, "Erik Michaels-Ober".freeze]
  s.date = "2024-08-27"
  s.description = "A generic OAuth (1.0/1.0a) strategy for OmniAuth.".freeze
  s.email = ["michael@intridea.com".freeze, "sferik@gmail.com".freeze]
  s.homepage = "https://github.com/intridea/omniauth-oauth".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.19".freeze
  s.summary = "A generic OAuth (1.0/1.0a) strategy for OmniAuth.".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<omniauth>.freeze, [">= 1.0", "< 3"])
  s.add_runtime_dependency(%q<oauth>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<rack>.freeze, [">= 1.6.2", "< 4"])
end
