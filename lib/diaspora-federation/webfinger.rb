# This module provides the namespace for the various classes implementing
# WebFinger and other protocols used for metadata discovery on remote servers
# in the Diaspora* network.
module DiasporaFederation
  module WebFinger
    require 'diaspora-federation/webfinger/xrd_document'
    require 'diaspora-federation/webfinger/host_meta'
    require 'diaspora-federation/webfinger/web_finger'
    require 'diaspora-federation/webfinger/h_card'
  end
end
