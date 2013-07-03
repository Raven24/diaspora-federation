module DiasporaFederation; module Entities
  class Retraction < Entity

    set_allowed_props :post_guid,
                      :diaspora_handle,
                      :type

  end
end; end
