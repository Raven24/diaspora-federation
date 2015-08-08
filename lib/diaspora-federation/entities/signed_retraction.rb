module DiasporaFederation
  module Entities
    class SignedRetraction < Entity
      define_props do
        property :target_guid
        property :target_type
        property :sender_handle
        property :target_author_signature
      end
    end
  end
end
