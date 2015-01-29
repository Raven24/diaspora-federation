require 'spec_helper'

describe Validators::RelayableRetractionValidator do
  it 'validates a well-formed instance' do
    c = OpenStruct.new(Fabricate.attributes_for(:relayable_retraction))
    v = Validators::RelayableRetractionValidator.new(c)
    expect(v).to be_valid
    expect(v.errors).to be_empty
  end

  it_behaves_like 'a diaspora_handle validator' do
    let(:entity) { :relayable_retraction }
    let(:validator) { Validators::RelayableRetractionValidator }
    let(:property) { :sender_handle }
  end

  it_behaves_like 'a guid validator' do
    let(:entity) { :relayable_retraction }
    let(:validator) { Validators::RelayableRetractionValidator }
    let(:property) { :target_guid }
  end

  context '#parent_author_signature, #target_author_signature' do
    [:parent_author_signature, :target_author_signature].each do |prop|
      it 'must not be empty' do
        r = OpenStruct.new(Fabricate.attributes_for(:relayable_retraction))
        r.public_send("#{prop}=", '')

        v = Validators::RelayableRetractionValidator.new(r)
        expect(v).to_not be_valid
        expect(v.errors).to include(prop)
      end
    end
  end
end
