# gems
require 'nokogiri'
require 'validation'
require 'base64'
require 'openssl'
require 'json'

# This is the main namespace used throughout this gem.
module DiasporaFederation
  # XML namespace url
  XMLNS = 'https://joindiaspora.com/protocol'
end

require 'diaspora-federation/validators'
require 'diaspora-federation/properties_dsl'
require 'diaspora-federation/entity'
require 'diaspora-federation/entities'
require 'diaspora-federation/xml_payload'
require 'diaspora-federation/salmon'
require 'diaspora-federation/webfinger'
