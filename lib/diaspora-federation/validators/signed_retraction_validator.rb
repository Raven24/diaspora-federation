module DiasporaFederation; module Validators
  class SignedRetractionValidator < Validation::Validator
    include Validation

    rule :target_guid, :guid

    rule :target_type, :not_empty

    rule :sender_handle, [:not_empty, :email]

    rule :target_author_signature, :not_empty

  end
end; end
