module DiasporaFederation; module Validators
  class RequestValidator < Validation::Validator
    include Validation

    rule :sender_handle, [:not_empty, :email]

    rule :recipient_handle, [:not_empty, :email]

  end
end; end
