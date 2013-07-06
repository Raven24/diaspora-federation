module DiasporaFederation; module Validators
  class CommentValidator < Validation::Validator
    include Validation

    rule :guid, :guid

    rule :parent_guid, :guid

    rule :parent_author_signature, :not_empty

    rule :author_signature, :not_empty

    rule :text, [:not_empty,
                 length: { maximum: 65535 }]

    rule :diaspora_handle, [:not_empty, :email]

  end
end; end
