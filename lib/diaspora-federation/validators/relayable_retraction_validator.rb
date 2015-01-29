module DiasporaFederation
  module Validators
    class RelayableRetractionValidator < Validation::Validator
      include Validation

      rule :parent_author_signature, :not_empty

      rule :target_guid, :guid

      rule :target_type, :not_empty

      rule :sender_handle, [:not_empty, :email]

      rule :target_author_signature, :not_empty
    end
  end
end
