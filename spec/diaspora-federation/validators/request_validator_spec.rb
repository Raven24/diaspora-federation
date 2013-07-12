require 'spec_helper'

describe Validators::RequestValidator do
  it 'validates a well-formed instance' do
    c = OpenStruct.new(Fabricate.attributes_for(:request))
    v = Validators::RequestValidator.new(c)
    v.should be_valid
    v.errors.should be_empty
  end

  context '#sender_handle, #recipient_handle' do
    [:sender_handle, :recipient_handle].each do |prop|
      it_behaves_like 'a diaspora_handle validator' do
        let(:entity) { :request }
        let(:validator) { Validators::RequestValidator }
        let(:property) { prop }
      end
    end
  end
end
