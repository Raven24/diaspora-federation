module DiasporaFederation
  module Validators
    class ConversationValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      rule :diaspora_handle, [:not_empty, :email]

      rule :participant_handles, handle_count: { maximum: 20 }
    end
  end
end
