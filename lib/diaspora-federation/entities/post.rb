module DiasporaFederation; module Entities
  class Post < Entity

    set_allowed_props :guid,
                      :diaspora_handle,
                      :public,
                      :created_at,
                      :provider_display_name

  end
end; end
