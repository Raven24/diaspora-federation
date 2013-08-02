require 'spec_helper'

describe Entities::Conversation do
  before do
    @datetime = DateTime.now
  end

  let(:msg1) { Entities::Message.new(Fabricate.attributes_for(:message)) }
  let(:msg2) { Entities::Message.new(Fabricate.attributes_for(:message)) }
  let(:data) { {guid: Fabricate.sequence(:guid),
                subject: 'very interesting conversation subject',
                created_at: @datetime,
                messages: [msg1, msg2],
                diaspora_handle: Fabricate.sequence(:diaspora_handle),
                participant_handles: "#{Fabricate.sequence(:diaspora_handle)};#{Fabricate.sequence(:diaspora_handle)}"} }

  let(:xml) { <<-XML
<conversation>
  <guid>#{data[:guid]}</guid>
  <subject>#{data[:subject]}</subject>
  <created_at>#{data[:created_at]}</created_at>
  <message>
    <guid>#{msg1.guid}</guid>
    <parent_guid>#{msg1.parent_guid}</parent_guid>
    <parent_author_signature>#{msg1.parent_author_signature}</parent_author_signature>
    <author_signature>#{msg1.author_signature}</author_signature>
    <text>#{msg1.text}</text>
    <created_at>#{msg1.created_at}</created_at>
    <diaspora_handle>#{msg1.diaspora_handle}</diaspora_handle>
    <conversation_guid>#{msg1.conversation_guid}</conversation_guid>
  </message>
  <message>
    <guid>#{msg2.guid}</guid>
    <parent_guid>#{msg2.parent_guid}</parent_guid>
    <parent_author_signature>#{msg2.parent_author_signature}</parent_author_signature>
    <author_signature>#{msg2.author_signature}</author_signature>
    <text>#{msg2.text}</text>
    <created_at>#{msg2.created_at}</created_at>
    <diaspora_handle>#{msg2.diaspora_handle}</diaspora_handle>
    <conversation_guid>#{msg2.conversation_guid}</conversation_guid>
  </message>
  <diaspora_handle>#{data[:diaspora_handle]}</diaspora_handle>
  <participant_handles>#{data[:participant_handles]}</participant_handles>
</conversation>
XML
  }

  it_behaves_like "an Entity subclass" do
    let(:klass) { Entities::Conversation }
  end
end
