lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'diaspora-federation/version'

Gem::Specification.new do |s|
  s.name        = 'diaspora-federation'
  s.version     = DiasporaFederation::VERSION
  s.date        = '2013-06-28'
  s.summary     = 'Diaspora* Federation module'
  s.description = 'This gem provides all functionality for communication among various installations of Diaspora*'
  s.authors     = ['Florian Staudacher']
  s.email       = 'florian_staudacher@yahoo.de'
  s.homepage    = 'https://github.com/'

  s.required_ruby_version = '>= 1.9.3'

  s.require_paths = ["lib"]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")

  s.add_dependency 'valid', '0.3.1'
  s.add_dependency 'ox', '2.0.4'

  s.add_development_dependency 'rake', '10.1.0'
  s.add_development_dependency 'rspec', '2.13.0'
end
