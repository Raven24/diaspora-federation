module DiasporaFederation; module Entities
  class Like < Entity

    set_allowed_props :positive,
                      :guid,
                      :target_type,
                      :parent_guid,
                      :parent_author_signature, # why?
                      :author_signature,        # why?
                      :diaspora_handle

  end
end; end
