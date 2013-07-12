require 'spec_helper'

describe Validators::RetractionValidator do
  it 'validates a well-formed instance' do
    c = OpenStruct.new(Fabricate.attributes_for(:retraction))
    v = Validators::RetractionValidator.new(c)
    v.should be_valid
    v.errors.should be_empty
  end

  it_behaves_like 'a guid validator' do
    let(:entity) { :retraction }
    let(:validator) { Validators::RetractionValidator }
    let(:property) { :post_guid }
  end

  it_behaves_like 'a diaspora_handle validator' do
    let(:entity) { :retraction }
    let(:validator) { Validators::RetractionValidator }
    let(:property) { :diaspora_handle }
  end

  context '#type' do
    it 'must not be emtpy' do
      r = OpenStruct.new(Fabricate.attributes_for(:retraction, type: ''))
      v = Validators::RetractionValidator.new(r)
      v.should_not be_valid
      v.errors.should include(:type)
    end
  end
end
