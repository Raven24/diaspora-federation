module DiasporaFederation
  module Validators
    class StatusMessageValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      rule :diaspora_handle, [:not_empty, :email]

      rule :public, :boolean
    end
  end
end
