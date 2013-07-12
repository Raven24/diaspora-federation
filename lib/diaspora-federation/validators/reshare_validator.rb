module DiasporaFederation; module Validators
  class ReshareValidator < Validation::Validator
    include Validation

    rule :root_diaspora_id, [:not_empty, :email]

    rule :root_guid, :guid

    rule :guid, :guid

    rule :diaspora_handle, [:not_empty, :email]

    rule :public, :boolean

  end
end; end
