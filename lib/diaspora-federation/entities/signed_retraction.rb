module DiasporaFederation; module Entities
  class SignedRetraction < Entity

    set_allowed_props :target_guid,
                      :target_type,
                      :sender_handle,
                      :target_author_signature

  end
end; end
