
Fabricate.sequence(:diaspora_handle) { |i| "d_user#{sprintf('%02d', i)}@pod.example.tld" }
Fabricate.sequence(:guid) { |i| "abcdef#{ sprintf('%010d', i)}" }
Fabricate.sequence(:signature) do |i|
  abc = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  ltr = abc[i % abc.length]
  "#{ltr * 6}=="
end

include DiasporaFederation::Entities

Fabricator(:message) do
  guid { Fabricate.sequence(:guid) }
  parent_guid { Fabricate.sequence(:guid) }
  parent_author_signature { Fabricate.sequence(:signature) }
  author_signature { Fabricate.sequence(:signature) }
  text 'this is a very informative text'
  created_at { DateTime.now }
  diaspora_handle { Fabricate.sequence(:diaspora_handle) }
  conversation_guid { Fabricate.sequence(:guid) }
end

Fabricator(:profile) do
  diaspora_handle { Fabricate.sequence(:diaspora_handle) }
  first_name 'FirstName'
  last_name ''
  image_url '/some/image.jpg'
  image_url_medium ''
  image_url_small ''
  birthday { Date.today }
  gender 'yes, please'
  bio 'i am so interesting'
  location 'Earth'
  searchable true
  nsfw false
  tag_string '#i #love #tags'
end

Fabricator(:location) do
  address 'Vienna, Austria'
  lat 48.208174
  lng 16.373819
end

Fabricator(:photo) do
  guid { Fabricate.sequence(:guid) }
  diaspora_handle { Fabricate.sequence(:diaspora_handle) }
  public(true)
  created_at { DateTime.now }
  remote_photo_path 'https://diaspora.example.tld/uploads/images/'
  remote_photo_name 'f2a41e9d2db4d9a199c8.jpg'
  text 'what you see here...'
  status_message_guid { Fabricate.sequence(:guid) }
  height 480
  width 800
end
