require 'spec_helper'

describe Validators::ConversationValidator do
  it 'validates a well-formed instance' do
    c = OpenStruct.new(Fabricate.attributes_for(:conversation))
    v = Validators::ConversationValidator.new(c)
    expect(v).to be_valid
    expect(v.errors).to be_empty
  end

  it_behaves_like 'a diaspora_handle validator' do
    let(:entity) { :conversation }
    let(:validator) { Validators::ConversationValidator }
    let(:property) { :diaspora_handle }
  end

  it_behaves_like 'a guid validator' do
    let(:entity) { :conversation }
    let(:validator) { Validators::ConversationValidator }
    let(:property) { :guid }
  end

  context 'participant_handles' do
    it 'must not contain more than 20 participant handles' do
      handles = 21.times.map { Fabricate.sequence(:diaspora_handle) }.join(';')
      c = OpenStruct.new(Fabricate.attributes_for(:conversation, participant_handles: handles))
      v = Validators::ConversationValidator.new(c)
      expect(v).to_not be_valid
      expect(v.errors).to include(:participant_handles)
    end
  end
end
