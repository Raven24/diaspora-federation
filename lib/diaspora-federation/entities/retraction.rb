module DiasporaFederation
  module Entities
    class Retraction < Entity
      define_props do
        property :post_guid
        property :diaspora_handle
        property :type
      end
    end
  end
end
