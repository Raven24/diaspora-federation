module DiasporaFederation; module Entities
  class Reshare < Entity

    define_props do
      property :root_diaspora_id  # inconsistent, everywhere else it's "handle"
      property :root_guid
      property :guid
      property :diaspora_handle
      property :public,  default: true # always true? (we only reshare public posts)
      property :created_at, default: -> { Time.now.utc }
      property :provider_display_name, default: nil
    end

  end
end; end
