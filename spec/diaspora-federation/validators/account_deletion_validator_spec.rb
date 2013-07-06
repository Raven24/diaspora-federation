require 'spec_helper'

describe Validators::AccountDeletionValidator do
  it_behaves_like 'a diaspora_handle validator' do
    let(:entity) { :account_deletion }
    let(:validator) { Validators::AccountDeletionValidator }
    let(:property) { :diaspora_handle }
  end
end
