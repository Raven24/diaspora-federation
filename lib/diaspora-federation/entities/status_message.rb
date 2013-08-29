module DiasporaFederation; module Entities
  class StatusMessage < Entity

    define_props do
      property :raw_message
      entity :photos, [Entities::Photo], default: []
      entity :location, Entities::Location, default: nil
      property :guid
      property :diaspora_handle
      property :public, default: false
      property :created_at, default: -> { Time.now.utc }
      property :provider_display_name, default: nil
    end

  end
end; end
