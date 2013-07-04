module DiasporaFederation; module Entities
  class Participation < Entity

    define_props do
      property :guid
      property :target_type
      property :parent_guid
      property :parent_author_signature
      property :author_signature
      property :diaspora_handle
    end

  end
end; end
