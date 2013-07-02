require 'spec_helper'

describe Entities::Profile do
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
  <birthday>#{Date.today}</birthday>
  <gender>something</gender>
  <bio>i am interesting</bio>
  <location>Earth</location>
  <searchable>false</searchable>
  <nsfw>false</nsfw>
  <tag_string>#i #love #tags</tag_string>
</profile>
XML
  }

  it_behaves_like "an Entity subclass" do
    let(:klass) { Entities::Profile }
  end
end
