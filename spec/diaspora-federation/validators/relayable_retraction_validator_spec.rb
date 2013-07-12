require 'spec_helper'

describe Validators::RelayableRetractionValidator do
  it 'validates a well-formed instance' do
    c = OpenStruct.new(Fabricate.attributes_for(:relayable_retraction))
    v = Validators::RelayableRetractionValidator.new(c)
    v.should be_valid
    v.errors.should be_empty
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
        r.public_send("#{prop.to_s}=", '')

        v = Validators::RelayableRetractionValidator.new(r)
        v.should_not be_valid
        v.errors.should include(prop)
      end
    end
  end
end
