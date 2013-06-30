require 'spec_helper'

describe Profile do
  let(:data) { {diaspora_handle: 'test@test.test',
                first_name: 'name',
                last_name: '',
                image_url: '/some/image.jpg',
                image_url_medium: '',
                image_url_small: '',
                birthday: Date.today,
                gender: 'something',
                bio: 'i am interesting',
                location: 'Earth',
                searchable: false,
                nsfw: false,
                tag_string: '#i #love #tags'} }

  let(:xml) { <<-XML

<profile>
  <diaspora_handle>test@test.test</diaspora_handle>
  <first_name>name</first_name>
  <last_name/>
  <image_url>/some/image.jpg</image_url>
  <image_url_medium/>
  <image_url_small/>
  <birthday>#{Date.today.to_s}</birthday>
  <gender>something</gender>
  <bio>i am interesting</bio>
  <location>Earth</location>
  <searchable>false</searchable>
  <nsfw>false</nsfw>
  <tag_string>#i #love #tags</tag_string>
</profile>
XML
  }

  it 'should be an Entity' do
    Profile.should be < Entity
  end

  it 'has its properties set' do
    Profile.class_props.should include(:diaspora_handle,
                                       :first_name,
                                       :last_name,
                                       :image_url,
                                       :image_url_medium,
                                       :image_url_small,
                                       :birthday,
                                       :gender,
                                       :bio,
                                       :location,
                                       :searchable,
                                       :nsfw,
                                       :tag_string)
  end

  context 'behaviour' do
    subject { Profile.new(data) }

    its(:to_h) { should == data }

    it 'produces correct XML' do
      Ox.dump(subject.to_xml).should eql(xml)
    end
  end
end
