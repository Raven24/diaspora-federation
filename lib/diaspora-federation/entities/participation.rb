module DiasporaFederation; module Entities
  class Participation < Entity

    set_allowed_props :guid,
                      :target_type,
                      :parent_guid,
                      :parent_author_signature,
                      :author_signature,
                      :diaspora_handle

  end
end; end
