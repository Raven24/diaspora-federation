
# This namespace contains all the entities used to encapsulate data that is
# passed around in the Diaspora* network as part of the federation protocol.
#
# All entities must be defined in this namespace. otherwise the XML
# de-serialization will fail.
module DiasporaFederation::Entities
end

# stand-alone
require 'diaspora-federation/entities/account_deletion'
require 'diaspora-federation/entities/comment'
require 'diaspora-federation/entities/like'
require 'diaspora-federation/entities/location'
require 'diaspora-federation/entities/message'
require 'diaspora-federation/entities/participation'
require 'diaspora-federation/entities/photo'
require 'diaspora-federation/entities/profile'
require 'diaspora-federation/entities/relayable_retraction'
require 'diaspora-federation/entities/request'
require 'diaspora-federation/entities/reshare'
require 'diaspora-federation/entities/retraction'
require 'diaspora-federation/entities/signed_retraction'

# nested
require 'diaspora-federation/entities/conversation'
require 'diaspora-federation/entities/person'
require 'diaspora-federation/entities/status_message'
