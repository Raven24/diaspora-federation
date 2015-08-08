require 'spec_helper'

describe Validators::PersonValidator do
  it 'validates a well-formed instance' do
    c = OpenStruct.new(Fabricate.attributes_for(:person))
    v = Validators::PersonValidator.new(c)
    expect(v).to be_valid
    expect(v.errors).to be_empty
  end

  it_behaves_like 'a diaspora_handle validator' do
    let(:entity) { :person }
    let(:validator) { Validators::PersonValidator }
    let(:property) { :diaspora_handle }
  end

  it_behaves_like 'a guid validator' do
    let(:entity) { :person }
    let(:validator) { Validators::PersonValidator }
    let(:property) { :guid }
  end

  context '#exported_key' do
    it 'fails for malformed rsa key' do
      c = OpenStruct.new(Fabricate.attributes_for(:person, exported_key: 'ASDF'))
      v = Validators::PersonValidator.new(c)
      expect(v).to_not be_valid
      expect(v.errors).to include(:exported_key)
    end

    it 'must not be empty' do
      c = OpenStruct.new(Fabricate.attributes_for(:person, exported_key: ''))
      v = Validators::PersonValidator.new(c)
      expect(v).to_not be_valid
      expect(v.errors).to include(:exported_key)
    end
  end
end
