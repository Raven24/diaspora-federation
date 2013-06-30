module DiasporaFederation; module Validators
  class ProfileValidator < Validation::Validator
    include Validation

    rule :diaspora_handle, [:not_empty, :email]

    rule :first_name, [length: { maximum: 32 },
                      format: { with: /\A[^;]+\z/, allow_blank: true }]

    rule :last_name, [length: { maximum: 32 },
                      format: { with: /\A[^;]+\z/, allow_blank: true }]

    rule :tag_string, tag_count: { maximum: 5 }

    rule :birthday, :birthday

    rule :searchable, :boolean

    rule :nsfw, :boolean
  end
end; end
