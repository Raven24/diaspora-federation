module DiasporaFederation; module Entities
  class Message < Entity

    set_allowed_props :guid,
                      :parent_guid,
                      :parent_author_signature, # why?
                      :author_signature,        # why?
                      :text,
                      :created_at,
                      :diaspora_handle,
                      :conversation_guid

  end
end; end
