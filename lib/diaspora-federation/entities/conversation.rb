module DiasporaFederation; module Entities
  class Conversation < Entity

    define_props do
      property :guid
      property :subject
      property :created_at
      entity :messages, [Entities::Message]
      property :diaspora_handle
      property :participant_handles
    end

  end
end; end
