require 'spec_helper'

describe ProfileValidator do
  let(:profile) do
    OpenStruct.new(diaspora_handle: 'testing@testpod.com',
                   first_name: 'my_name',
                   last_name: '',
                   tag_string: '#i #love #tags',
                   birthday: '1990-07-26',
                   searchable: 'true',
                   nsfw: 'false')
  end

  it 'validates a well-formed instance' do
    v = ProfileValidator.new(profile)
    v.should be_valid
  end

  context '#diaspora_handle' do
    it 'must not be empty' do
      test = profile.clone
      test.diaspora_handle = ''

      v = ProfileValidator.new(test)
      v.should_not be_valid
      v.errors.should include(:diaspora_handle)
    end

    it 'must resemble an email address' do
      test = profile.clone
      test.diaspora_handle = 'i am a weird handle @@@ ### 12345'

      v = ProfileValidator.new(test)
      v.should_not be_valid
      v.errors.should include(:diaspora_handle)
    end
  end

  context '#first_name and #last_name' do
    [:first_name, :last_name].each do |prop|
      it 'must not exceed 32 chars' do
        test = profile.clone
        test.send("#{prop}=", "abcdefghijklmnopqrstuvwxyz_aaaaaaaaaa")

        v = ProfileValidator.new(test)
        v.should_not be_valid
        v.errors.should include(prop)
      end

      it 'must not contain semicolons' do
        test = profile.clone
        test.send("#{prop}=", "asdf;qwer;yxcv")

        v = ProfileValidator.new(test)
        v.should_not be_valid
        v.errors.should include(prop)
      end
    end
  end

  context '#tag_string' do
    it 'must not contain more than 5 tags' do
      test = profile.clone
      test.tag_string = "#i #have #too #many #tags #in #my #profile"

      v = ProfileValidator.new(test)
      v.should_not be_valid
      v.errors.should include(:tag_string)
    end
  end

  context '#birthday' do
    it 'may be empty or nil' do
      [nil, ''].each do |val|
        test = profile.clone
        test.birthday = val

        v = ProfileValidator.new(test)
        v.should be_valid
        v.errors.should be_empty
      end
    end

    it 'may be a Date or date string' do
      [Date.parse('2013-06-29'), '2013-06-29'].each do |val|
        test = profile.clone
        test.birthday = val

        v = ProfileValidator.new(test)
        v.should be_valid
        v.errors.should be_empty
      end
    end

    it 'must not be an arbitrary string or other object' do
      ['asdf asdf', true, 1234].each do |val|
        test = profile.clone
        test.birthday = val

        v = ProfileValidator.new(test)
        v.should_not be_valid
        v.errors.should include(:birthday)
      end
    end
  end

  context '#searchable and #nsfw' do
    [:searchable, :nsfw].each do |prop|
      it 'may be a boolean' do
        [true, 'true', false, 'false'].each do |val|
          test = profile.clone
          test.send("#{prop}=", val)

          v = ProfileValidator.new(test)
          v.should be_valid
          v.errors.should be_empty
        end
      end

      it 'must not be an arbitrary string or other object' do
        ['asdf', Date.today, 1234].each do |val|
          test = profile.clone
          test.send("#{prop}=", val)

          v = ProfileValidator.new(test)
          v.should_not be_valid
          v.errors.should include(prop)
        end
      end
    end
  end
end
