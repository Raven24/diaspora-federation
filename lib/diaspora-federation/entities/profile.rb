module DiasporaFederation; module Entities
  class Profile < Entity

    define_props do
      property :diaspora_handle
      property :first_name
      property :last_name
      property :image_url
      property :image_url_medium
      property :image_url_small
      property :birthday
      property :gender
      property :bio
      property :location
      property :searchable
      property :nsfw
      property :tag_string
    end

  end
end; end
