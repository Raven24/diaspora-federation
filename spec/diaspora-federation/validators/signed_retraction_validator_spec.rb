require 'spec_helper'

describe Validators::SignedRetractionValidator do
  it 'validates a well-formed instance' do
    c = OpenStruct.new(Fabricate.attributes_for(:signed_retraction))
    v = Validators::SignedRetractionValidator.new(c)
    expect(v).to be_valid
    expect(v.errors).to be_empty
  end

  it_behaves_like 'a diaspora_handle validator' do
    let(:entity) { :signed_retraction }
    let(:validator) { Validators::SignedRetractionValidator }
    let(:property) { :sender_handle }
  end

  it_behaves_like 'a guid validator' do
    let(:entity) { :signed_retraction }
    let(:validator) { Validators::SignedRetractionValidator }
    let(:property) { :target_guid }
  end

  context '#target_type, #target_author_signature' do
    [:target_type, :target_author_signature].each do |prop|
      it 'must not be empty' do
        r = OpenStruct.new(Fabricate.attributes_for(:signed_retraction))
        r.public_send("#{prop}=", '')

        v = Validators::SignedRetractionValidator.new(r)
        expect(v).to_not be_valid
        expect(v.errors).to include(prop)
      end
    end
  end
end
