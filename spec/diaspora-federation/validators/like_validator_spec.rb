require 'spec_helper'

describe Validators::LikeValidator do
  it 'validates a well-formed instance' do
    l = OpenStruct.new(Fabricate.attributes_for(:like))
    v = Validators::LikeValidator.new(l)
    v.should be_valid
    v.errors.should be_empty
  end

  [:guid, :parent_guid].each do |prop|
    it_behaves_like 'a guid validator' do
      let(:entity) { :like }
      let(:validator) { Validators::LikeValidator }
      let(:property) { prop }
    end
  end

  context '#author_signature and #parent_author_signature' do
    [:author_signature, :parent_author_signature].each do |prop|
      it 'must not be empty' do
        like = OpenStruct.new(Fabricate.attributes_for(:like))
        like.public_send("#{prop.to_s}=", '')

        v = Validators::LikeValidator.new(like)
        v.should_not be_valid
        v.errors.should include(prop)
      end
    end
  end

  it_behaves_like 'a diaspora_handle validator' do
    let(:entity) { :like }
    let(:validator) { Validators::LikeValidator }
    let(:property) { :diaspora_handle }
  end
end
