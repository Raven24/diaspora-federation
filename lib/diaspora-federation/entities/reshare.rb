module DiasporaFederation; module Entities
  class Reshare < Entity

    set_allowed_props :root_diaspora_id,  # inconsistent, everywhere else it's "handle"
                      :root_guid,
                      :guid,
                      :diaspora_handle,
                      :public,            # always true? (we only reshare public posts)
                      :created_at,
                      :provider_display_name

  end
end; end
