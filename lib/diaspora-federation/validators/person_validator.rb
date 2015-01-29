module DiasporaFederation
  module Validators
    class PersonValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      rule :diaspora_handle, [:not_empty, :email]

      # rule :url ...

      rule :exported_key, :rsa_key
    end
  end
end
