module DiasporaFederation
  module Entities
    class Person < Entity
      define_props do
        property :guid
        property :diaspora_handle
        property :url
        entity :profile, Entities::Profile
        property :exported_key
      end
    end
  end
end
