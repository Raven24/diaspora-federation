module DiasporaFederation; module Entities
  class Participation < Entity

    set_allowed_props :guid,
                      :target_type,
                      :parent_guid,
                      :parent_author_signature, # why?
                      :author_signature,        # why?
                      :diaspora_handle

  end
end; end
