require 'spec_helper'

describe Validators::CommentValidator do
  it 'validates a well-formed instance' do
    v = Validators::CommentValidator.new(OpenStruct.new(Fabricate.attributes_for(:comment)))
    expect(v).to be_valid
    expect(v.errors).to be_empty
  end

  it_behaves_like 'a diaspora_handle validator' do
    let(:entity) { :comment }
    let(:validator) { Validators::CommentValidator }
    let(:property) { :diaspora_handle }
  end

  [:guid, :parent_guid].each do |prop|
    it_behaves_like 'a guid validator' do
      let(:entity) { :comment }
      let(:validator) { Validators::CommentValidator }
      let(:property) { prop }
    end
  end

  context '#author_signature and #parent_author_signature' do
    [:author_signature, :parent_author_signature].each do |prop|
      it 'must not be empty' do
        comment = OpenStruct.new(Fabricate.attributes_for(:comment))
        comment.public_send("#{prop}=", '')

        v = Validators::CommentValidator.new(comment)
        expect(v).to_not be_valid
        expect(v.errors).to include(prop)
      end
    end
  end

  context '#text' do
    it 'must not be emtpy' do
      v = Validators::CommentValidator.new(OpenStruct.new(Fabricate.attributes_for(:comment, text: '')))
      expect(v).to_not be_valid
      expect(v.errors).to include(:text)
    end

    it 'must not exceed 65535 chars' do
      v = Validators::CommentValidator.new(
            OpenStruct.new(
              Fabricate.attributes_for(:comment, text: 'a' * 65_536)))
      expect(v).to_not be_valid
      expect(v.errors).to include(:text)
    end
  end
end
