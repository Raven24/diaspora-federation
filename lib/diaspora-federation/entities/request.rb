module DiasporaFederation; module Entities
  class Request < Entity

    define_props do
      property :sender_handle
      property :recipient_handle
    end

  end
end; end
