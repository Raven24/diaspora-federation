require 'spec_helper'

describe Entities::Photo do
  before do
    @datetime = DateTime.now
  end

  let(:data) { {guid: '0123456789abcdef',
                diaspora_handle: 'luke@diaspora.example.tld',
                public: true,
                created_at: @datetime,
                remote_photo_path: 'https://diaspora.example.tld/uploads/images/',
                remote_photo_name: 'f2a41e9d2db4d9a199c8.jpg',
                text: 'what you see here...',
                status_message_guid: 'fedcba9876543210',
                height: 480,
                width: 800} }

  let(:xml) { <<-XML

<photo>
  <guid>0123456789abcdef</guid>
  <diaspora_handle>luke@diaspora.example.tld</diaspora_handle>
  <public>true</public>
  <created_at>#{@datetime}</created_at>
  <remote_photo_path>https://diaspora.example.tld/uploads/images/</remote_photo_path>
  <remote_photo_name>f2a41e9d2db4d9a199c8.jpg</remote_photo_name>
  <text>what you see here...</text>
  <status_message_guid>fedcba9876543210</status_message_guid>
  <height>480</height>
  <width>800</width>
</photo>
XML
  }

  it_behaves_like "an Entity subclass" do
    let(:klass) { Entities::Photo }
  end
end
