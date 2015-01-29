module DiasporaFederation
  module Validators
    class RetractionValidator < Validation::Validator
      include Validation

      rule :post_guid, :guid

      rule :diaspora_handle, [:not_empty, :email]

      rule :type, :not_empty
    end
  end
end
