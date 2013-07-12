require 'spec_helper'

describe Validators::StatusMessageValidator do
  it 'validates a well-formed instance' do
    c = OpenStruct.new(Fabricate.attributes_for(:status_message))
    v = Validators::StatusMessageValidator.new(c)
    v.should be_valid
    v.errors.should be_empty
  end

  it_behaves_like 'a diaspora_handle validator' do
    let(:entity) { :status_message }
    let(:validator) { Validators::StatusMessageValidator }
    let(:property) { :diaspora_handle }
  end

  it_behaves_like 'a guid validator' do
    let(:entity) { :status_message }
    let(:validator) { Validators::StatusMessageValidator }
    let(:property) { :guid }
  end

  it_behaves_like 'a boolean validator' do
    let(:entity) { :status_message }
    let(:validator) { Validators::StatusMessageValidator }
    let(:property) { :public }
  end
end
