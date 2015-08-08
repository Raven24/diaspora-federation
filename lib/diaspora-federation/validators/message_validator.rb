module DiasporaFederation
  module Validators
    class MessageValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      rule :parent_guid, :guid

      rule :parent_author_signature, :not_empty

      rule :author_signature, :not_empty

      rule :diaspora_handle, [:not_empty, :email]

      rule :conversation_guid, :guid
    end
  end
end
