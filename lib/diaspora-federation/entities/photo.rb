module DiasporaFederation; module Entities
  class Photo < Entity

    define_props do
      property :guid
      property :diaspora_handle
      property :public
      property :created_at
      property :remote_photo_path
      property :remote_photo_name
      property :text
      property :status_message_guid
      property :height
      property :width
    end

  end
end; end
