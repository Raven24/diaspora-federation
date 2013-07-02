module DiasporaFederation; module Entities
  class Photo < Entity

    set_allowed_props :guid,
                      :diaspora_handle,
                      :public,
                      :created_at,
                      :remote_photo_path,
                      :remote_photo_name,
                      :text,
                      :status_message_guid,
                      :height,
                      :width

  end
end; end
