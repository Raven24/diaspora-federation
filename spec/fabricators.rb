
Fabricate.sequence(:diaspora_handle) { |i| "d_user#{sprintf('%02d', i)}@pod.example.tld" }
Fabricate.sequence(:guid) { |i| "abcdef#{ sprintf('%010d', i)}" }
Fabricate.sequence(:signature) do |i|
  abc = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  ltr = abc[i % abc.length]
  "#{ltr * 6}=="
end

include DiasporaFederation::Entities

Fabricator(:account_deletion) do
  diaspora_handle { Fabricate.sequence(:diaspora_handle) }
end

Fabricator(:comment) do
  guid { Fabricate.sequence(:guid) }
  parent_guid { Fabricate.sequence(:guid) }
  parent_author_signature { Fabricate.sequence(:signature) }
  author_signature { Fabricate.sequence(:signature) }
  text 'this is a very informative comment'
  diaspora_handle { Fabricate.sequence(:diaspora_handle) }
end

Fabricator(:conversation) do
  guid { Fabricate.sequence(:guid) }
  subject 'this is a very informative subject'
  created_at { DateTime.now }
  messages []
  diaspora_handle { Fabricate.sequence(:diaspora_handle) }
  participant_handles { 3.times.map{ Fabricate.sequence(:diaspora_handle) }.join(';') }
end

Fabricator(:like) do
  positive 1
  guid { Fabricate.sequence(:guid) }
  target_type 'StatusMessage'
  parent_guid { Fabricate.sequence(:guid) }
  parent_author_signature { Fabricate.sequence(:signature) }
  author_signature { Fabricate.sequence(:signature) }
  diaspora_handle { Fabricate.sequence(:diaspora_handle) }
end

Fabricator(:location) do
  address 'Vienna, Austria'
  lat 48.208174.to_s
  lng 16.373819.to_s
end

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
