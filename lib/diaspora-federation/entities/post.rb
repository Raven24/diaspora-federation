module DiasporaFederation; module Entities
  class Post < Entity

    define_props do
      property :guid
      property :diaspora_handle
      property :public
      property :created_at
      property :provider_display_name
    end

  end
end; end
