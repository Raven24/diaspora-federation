require 'spec_helper'

describe Validators::ProfileValidator do
  def profile_stub(data = {})
    OpenStruct.new({ diaspora_handle: 'testing@testpod.com',
                     first_name: 'my_name',
                     last_name: '',
                     tag_string: '#i #love #tags',
                     birthday: '1990-07-26',
                     searchable: 'true',
                     nsfw: 'false' }.merge(data))
  end

  before do
    @profile = profile_stub
  end

  it 'validates a well-formed instance' do
    v = Validators::ProfileValidator.new(profile_stub)
    expect(v).to be_valid
  end

  it_behaves_like 'a diaspora_handle validator' do
    let(:entity) { :profile }
    let(:validator) { Validators::ProfileValidator }
    let(:property) { :diaspora_handle }
  end

  context '#first_name and #last_name' do
    [:first_name, :last_name].each do |prop|
      it 'must not exceed 32 chars' do
        @profile.public_send("#{prop}=", 'abcdefghijklmnopqrstuvwxyz_aaaaaaaaaa')
        v = Validators::ProfileValidator.new(@profile)
        expect(v).to_not be_valid
        expect(v.errors).to include(prop)
      end

      it 'must not contain semicolons' do
        @profile.public_send("#{prop}=", 'asdf;qwer;yxcv')
        v = Validators::ProfileValidator.new(@profile)
        expect(v).to_not be_valid
        expect(v.errors).to include(prop)
      end
    end
  end

  context '#tag_string' do
    it 'must not contain more than 5 tags' do
      v = Validators::ProfileValidator.new(profile_stub(tag_string: '#i #have #too #many #tags #in #my #profile'))
      expect(v).to_not be_valid
      expect(v.errors).to include(:tag_string)
    end
  end

  context '#birthday' do
    it 'may be empty or nil' do
      [nil, ''].each do |val|
        v = Validators::ProfileValidator.new(profile_stub(birthday: val))
        expect(v).to be_valid
        expect(v.errors).to be_empty
      end
    end

    it 'may be a Date or date string' do
      [Date.parse('2013-06-29'), '2013-06-29'].each do |val|
        v = Validators::ProfileValidator.new(profile_stub(birthday: val))
        expect(v).to be_valid
        expect(v.errors).to be_empty
      end
    end

    it 'must not be an arbitrary string or other object' do
      ['asdf asdf', true, 1234].each do |val|
        v = Validators::ProfileValidator.new(profile_stub(birthday: val))
        expect(v).to_not be_valid
        expect(v.errors).to include(:birthday)
      end
    end
  end

  context '#searchable and #nsfw' do
    [:searchable, :nsfw].each do |prop|
      it_behaves_like 'a boolean validator' do
        let(:entity) { :profile }
        let(:validator) { Validators::ProfileValidator }
        let(:property) { prop }
      end
    end
  end
end
