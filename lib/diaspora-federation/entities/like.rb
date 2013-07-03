module DiasporaFederation; module Entities
  class Like < Entity

    set_allowed_props :positive,
                      :guid,
                      :target_type,
                      :parent_guid,
                      :parent_author_signature,
                      :author_signature,
                      :diaspora_handle

  end
end; end
