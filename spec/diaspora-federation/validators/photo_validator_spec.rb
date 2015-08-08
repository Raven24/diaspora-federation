require 'spec_helper'

describe Validators::PhotoValidator do
  it 'validates a well-formed instance' do
    c = OpenStruct.new(Fabricate.attributes_for(:photo))
    v = Validators::PhotoValidator.new(c)
    expect(v).to be_valid
    expect(v.errors).to be_empty
  end

  it_behaves_like 'a diaspora_handle validator' do
    let(:entity) { :photo }
    let(:validator) { Validators::PhotoValidator }
    let(:property) { :diaspora_handle }
  end

  context '#guid, #status_message_guid' do
    [:guid, :status_message_guid].each do |prop|
      it_behaves_like 'a guid validator' do
        let(:entity) { :photo }
        let(:validator) { Validators::PhotoValidator }
        let(:property) { prop }
      end
    end
  end

  it_behaves_like 'a boolean validator' do
    let(:entity) { :photo }
    let(:validator) { Validators::PhotoValidator }
    let(:property) { :public }
  end

  context '#remote_photo_path, #remote_photo_name' do
    [:remote_photo_name, :remote_photo_path].each do |prop|
      it 'must not be empty' do
        p = OpenStruct.new(Fabricate.attributes_for(:photo))
        p.public_send("#{prop}=", '')

        v = Validators::PhotoValidator.new(p)
        expect(v).to_not be_valid
        expect(v.errors).to include(prop)
      end
    end
  end

  context '#height, #width' do
    [:height, :width].each do |prop|
      it 'validates an integer' do
        [123, '123'].each do |val|
          p = OpenStruct.new(Fabricate.attributes_for(:photo))
          p.public_send("#{prop}=", val)

          v = Validators::PhotoValidator.new(p)
          expect(v).to be_valid
          expect(v.errors).to be_empty
        end
      end

      it 'fails for non numeric types' do
        [true, :num, 'asdf'].each do |val|
          p = OpenStruct.new(Fabricate.attributes_for(:photo))
          p.public_send("#{prop}=", val)

          v = Validators::PhotoValidator.new(p)
          expect(v).to_not be_valid
          expect(v.errors).to include(prop)
        end
      end
    end
  end
end
