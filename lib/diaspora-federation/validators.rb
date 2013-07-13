
require 'validation/rule/not_empty'
require 'validation/rule/length'
require 'validation/rule/email'

# This module contains custom validation rules for various data field types.
# That includes types for which there are no provided rules by the +valid+ gem
# or types that are very specific to Diaspora* federation and need special handling.
# The rules are used inside the {DiasporaFederation::Validators validator classes}
# to perform basic santity-checks on {DiasporaFederation::Entities federation entities}.
module Validation::Rule
end

require 'diaspora-federation/validators/rules/birthday'
require 'diaspora-federation/validators/rules/boolean'
require 'diaspora-federation/validators/rules/format'
require 'diaspora-federation/validators/rules/guid'
require 'diaspora-federation/validators/rules/handle_count'
require 'diaspora-federation/validators/rules/numeric'
require 'diaspora-federation/validators/rules/rsa_key'
require 'diaspora-federation/validators/rules/tag_count'

require 'diaspora-federation/validators/account_deletion_validator'
require 'diaspora-federation/validators/comment_validator'
require 'diaspora-federation/validators/conversation_validator'
require 'diaspora-federation/validators/like_validator'
require 'diaspora-federation/validators/location_validator'
require 'diaspora-federation/validators/message_validator'
require 'diaspora-federation/validators/participation_validator'
require 'diaspora-federation/validators/person_validator'
require 'diaspora-federation/validators/photo_validator'
require 'diaspora-federation/validators/profile_validator'
require 'diaspora-federation/validators/relayable_retraction_validator'
require 'diaspora-federation/validators/request_validator'
require 'diaspora-federation/validators/reshare_validator'
require 'diaspora-federation/validators/retraction_validator'
require 'diaspora-federation/validators/signed_retraction_validator'
require 'diaspora-federation/validators/status_message_validator'
