module DiasporaFederation
  module Entities
    class Profile < Entity
      define_props do
        property :diaspora_handle
        property :first_name, default: nil
        property :last_name, default: nil
        property :image_url, default: nil
        property :image_url_medium, default: nil
        property :image_url_small, default: nil
        property :birthday, default: nil
        property :gender, default: nil
        property :bio, default: nil
        property :location, default: nil
        property :searchable, default: true
        property :nsfw, default: false
        property :tag_string, default: nil
      end
    end
  end
end
