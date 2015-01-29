require 'spec_helper'

describe Validators::ReshareValidator do
  it 'validates a well-formed instance' do
    c = OpenStruct.new(Fabricate.attributes_for(:reshare))
    v = Validators::ReshareValidator.new(c)
    expect(v).to be_valid
    expect(v.errors).to be_empty
  end

  context '#root_diaspora_id, #diaspora_handle' do
    [:root_diaspora_id, :diaspora_handle].each do |prop|
      it_behaves_like 'a diaspora_handle validator' do
        let(:entity) { :reshare }
        let(:validator) { Validators::ReshareValidator }
        let(:property) { prop }
      end
    end
  end

  context '#root_guid, #guid' do
    [:root_guid, :guid].each do |prop|
      it_behaves_like 'a guid validator' do
        let(:entity) { :reshare }
        let(:validator) { Validators::ReshareValidator }
        let(:property) { prop }
      end
    end
  end

  it_behaves_like 'a boolean validator' do
    let(:entity) { :reshare }
    let(:validator) { Validators::ReshareValidator }
    let(:property) { :public }
  end
end
