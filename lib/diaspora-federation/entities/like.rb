module DiasporaFederation; module Entities
  class Like < Entity

    define_props do
      property :positive
      property :guid
      property :target_type
      property :parent_guid
      property :parent_author_signature
      property :author_signature
      property :diaspora_handle
    end

  end
end; end
