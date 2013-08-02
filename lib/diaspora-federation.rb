
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

  # ensure the given string has got an xml prolog (primitively)
  # @param [String] Salmon XML
  # @return [String] Salmon XML, guaranteed with xml prolog
  def self.ensure_xml_prolog(xml_str)
    if xml_str.index('<?xml').nil?
      return '<?xml version="1.0" encoding="UTF-8"?>' + "\n" + xml_str
    end

    xml_str
  end
end

require 'diaspora-federation/validators'
require 'diaspora-federation/properties_dsl'
require 'diaspora-federation/entity'
require 'diaspora-federation/entities'
require 'diaspora-federation/xml_payload'
require 'diaspora-federation/salmon'
require 'diaspora-federation/webfinger'
