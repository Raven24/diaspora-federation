module DiasporaFederation
  module Validators
    class PhotoValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      rule :diaspora_handle, [:not_empty, :email]

      rule :public, :boolean

      rule :remote_photo_path, :not_empty

      rule :remote_photo_name, :not_empty

      rule :status_message_guid, :guid

      rule :height, :numeric

      rule :width, :numeric
    end
  end
end
