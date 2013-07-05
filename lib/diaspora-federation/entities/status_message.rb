module DiasporaFederation; module Entities
  class StatusMessage < Entity

    define_props do
      property :raw_message
      entity :photos, [Entities::Photo]
      entity :location, Entities::Location
      property :guid
      property :diaspora_handle
      property :public
      property :created_at
      property :provider_display_name
    end

  end
end; end
