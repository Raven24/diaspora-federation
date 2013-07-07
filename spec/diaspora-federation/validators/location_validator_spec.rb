require 'spec_helper'

describe Validators::LocationValidator do
  it 'validates a well-formed instance' do
    l = OpenStruct.new(Fabricate.attributes_for(:location))
    v = Validators::LocationValidator.new(l)
    v.should be_valid
    v.errors.should be_empty
  end

  context '#lat and #lng' do
    [:lat, :lng].each do |prop|
      it 'must not be empty' do
        l = OpenStruct.new(Fabricate.attributes_for(:location))
        l.public_send("#{prop.to_s}=", '')

        v = Validators::LocationValidator.new(l)
        v.should_not be_valid
        v.errors.should include(prop)
      end
    end
  end
end
