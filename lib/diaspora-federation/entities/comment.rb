module DiasporaFederation; module Entities
  class Comment < Entity

    set_allowed_props :guid,
                      :parent_guid,
                      :parent_author_signature, # why?
                      :author_signature,        # why?
                      :text,
                      :diaspora_handle

  end
end; end
