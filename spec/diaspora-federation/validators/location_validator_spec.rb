require 'spec_helper'

describe Validators::LocationValidator do
  it 'validates a well-formed instance' do
    l = OpenStruct.new(Fabricate.attributes_for(:location))
    v = Validators::LocationValidator.new(l)
    expect(v).to be_valid
    expect(v.errors).to be_empty
  end

  context '#lat and #lng' do
    [:lat, :lng].each do |prop|
      it 'must not be empty' do
        l = OpenStruct.new(Fabricate.attributes_for(:location))
        l.public_send("#{prop}=", '')

        v = Validators::LocationValidator.new(l)
        expect(v).to_not be_valid
        expect(v.errors).to include(prop)
      end
    end
  end
end
