require 'spec_helper'

describe Validators::MessageValidator do
  it 'validates a well-formed instance' do
    c = OpenStruct.new(Fabricate.attributes_for(:message))
    v = Validators::MessageValidator.new(c)
    expect(v).to be_valid
    expect(v.errors).to be_empty
  end

  it_behaves_like 'a diaspora_handle validator' do
    let(:entity) { :message }
    let(:validator) { Validators::MessageValidator }
    let(:property) { :diaspora_handle }
  end

  context '#guid, #parent_guid, #conversation_guid' do
    [:guid, :parent_guid, :conversation_guid].each do |prop|
      it_behaves_like 'a guid validator' do
        let(:entity) { :message }
        let(:validator) { Validators::MessageValidator }
        let(:property) { prop }
      end
    end
  end

  context '#author_signature and #parent_author_signature' do
    [:author_signature, :parent_author_signature].each do |prop|
      it 'must not be empty' do
        msg = OpenStruct.new(Fabricate.attributes_for(:message))
        msg.public_send("#{prop}=", '')

        v = Validators::MessageValidator.new(msg)
        expect(v).to_not be_valid
        expect(v.errors).to include(prop)
      end
    end
  end
end
