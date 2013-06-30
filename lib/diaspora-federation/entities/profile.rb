module DiasporaFederation; module Entities
  class Profile < Entity

    set_allowed_props :diaspora_handle,
                      :first_name,
                      :last_name,
                      :image_url,
                      :image_url_medium,
                      :image_url_small,
                      :birthday,
                      :gender,
                      :bio,
                      :location,
                      :searchable,
                      :nsfw,
                      :tag_string

  end
end; end
