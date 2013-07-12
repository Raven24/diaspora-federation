require 'spec_helper'

describe Validators::ParticipationValidator do
  it 'validates a well-formed instance' do
    c = OpenStruct.new(Fabricate.attributes_for(:participation))
    v = Validators::ParticipationValidator.new(c)
    v.should be_valid
    v.errors.should be_empty
  end

  it_behaves_like 'a diaspora_handle validator' do
    let(:entity) { :participation }
    let(:validator) { Validators::ParticipationValidator }
    let(:property) { :diaspora_handle }
  end

  context '#target_type' do
    it 'must not be empty' do
      p = OpenStruct.new(Fabricate.attributes_for(:participation, target_type: ''))
      v = Validators::ParticipationValidator.new(p)
      v.should_not be_valid
      v.errors.should include(:target_type)
    end
  end

  context '#guid, #parent_guid' do
    [:guid, :parent_guid].each do |prop|
      it_behaves_like 'a guid validator' do
        let(:entity) { :participation }
        let(:validator) { Validators::ParticipationValidator }
        let(:property) { prop }
      end
    end
  end

  context '#author_signature and #parent_author_signature' do
    [:author_signature, :parent_author_signature].each do |prop|
      it 'must not be empty' do
        p = OpenStruct.new(Fabricate.attributes_for(:participation))
        p.public_send("#{prop.to_s}=", '')

        v = Validators::ParticipationValidator.new(p)
        v.should_not be_valid
        v.errors.should include(prop)
      end
    end
  end

end
