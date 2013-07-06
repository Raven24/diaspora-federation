module DiasporaFederation; module Validators
  class AccountDeletionValidator < Validation::Validator
    include Validation

    rule :diaspora_handle, [:not_empty, :email]

  end
end; end
