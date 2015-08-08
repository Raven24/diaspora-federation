module DiasporaFederation
  module Entities
    class Message < Entity
      define_props do
        property :guid
        property :parent_guid
        property :parent_author_signature
        property :author_signature
        property :text
        property :created_at, default: -> { Time.now.utc }
        property :diaspora_handle
        property :conversation_guid
      end
    end
  end
end
