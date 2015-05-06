lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'diaspora-federation/version'

Gem::Specification.new do |s|
  s.name        = 'diaspora-federation'
  s.version     = DiasporaFederation::VERSION
  s.date        = '2013-06-28'
  s.license     = 'MIT'
  s.summary     = 'Diaspora* Federation module'
  s.description = 'This gem provides the functionality for de-/serialization and '+
                  'de-/encryption of Entities in the protocols used for communication '+
                  'among the various installations of Diaspora*'
  s.authors     = ['Florian Staudacher']
  s.email       = 'florian_staudacher@yahoo.de'
  s.homepage    = 'https://github.com/Raven24/diaspora-federation'

  s.required_ruby_version = '>= 1.9.3'

  s.require_paths = ["lib"]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")

  s.add_dependency 'valid', '~> 0.3.1'
  s.add_dependency 'nokogiri', '~> 1.6.0'

  s.add_development_dependency 'rake', '~> 10.1.0'
  s.add_development_dependency 'rspec', '~> 2.13.0'
  s.add_development_dependency 'fabrication', '~> 2.7.2'
end
