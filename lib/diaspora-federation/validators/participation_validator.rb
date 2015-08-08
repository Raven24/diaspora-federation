module DiasporaFederation
  module Validators
    class ParticipationValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      rule :target_type, :not_empty

      rule :parent_guid, :guid

      rule :parent_author_signature, :not_empty

      rule :author_signature, :not_empty

      rule :diaspora_handle, [:not_empty, :email]
    end
  end
end
