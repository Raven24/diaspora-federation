module DiasporaFederation; module Entities
  class Comment < Entity

    define_props do
      property :guid
      property :parent_guid
      property :parent_author_signature
      property :author_signature
      property :text
      property :diaspora_handle
    end

  end
end; end
