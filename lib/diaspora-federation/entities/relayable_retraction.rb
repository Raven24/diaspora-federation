module DiasporaFederation; module Entities
  class RelayableRetraction < Entity

    set_allowed_props :parent_author_signature,
                      :target_guid,
                      :target_type,
                      :sender_handle,
                      :target_author_signature

  end
end; end
