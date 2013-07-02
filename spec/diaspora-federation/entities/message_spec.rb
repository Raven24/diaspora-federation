require 'spec_helper'

describe Entities::Message do
  before do
    @datetime = DateTime.now
  end

  let(:data) { {guid: '0123456789abcdef',
                parent_guid: 'fedcba98765432310',
                parent_author_signature: 'BBBBBB==',
                author_signature: 'AAAAAA==',
                text: 'here is some text',
                created_at: @datetime,
                diaspora_handle: 'test@test.test',
                conversation_guid: 'fedcba98765432310'} }

  let(:xml) { <<-XML

<message>
  <guid>0123456789abcdef</guid>
  <parent_guid>fedcba98765432310</parent_guid>
  <parent_author_signature>BBBBBB==</parent_author_signature>
  <author_signature>AAAAAA==</author_signature>
  <text>here is some text</text>
  <created_at>#{@datetime}</created_at>
  <diaspora_handle>test@test.test</diaspora_handle>
  <conversation_guid>fedcba98765432310</conversation_guid>
</message>
XML
  }

  it_behaves_like "an Entity subclass" do
    let(:klass) { Entities::Message }
  end
end
