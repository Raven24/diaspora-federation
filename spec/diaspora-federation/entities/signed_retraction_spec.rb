require 'spec_helper'

describe Entities::SignedRetraction do
  let(:data) do
    { target_guid: '0123456789abcdef',
      target_type: 'StatusMessage',
      sender_handle: 'luke@diaspora.example.tld',
      target_author_signature: 'AAAAAA==' }
  end

  let(:xml) do
    <<-XML
<signed_retraction>
  <target_guid>0123456789abcdef</target_guid>
  <target_type>StatusMessage</target_type>
  <sender_handle>luke@diaspora.example.tld</sender_handle>
  <target_author_signature>AAAAAA==</target_author_signature>
</signed_retraction>
XML
  end

  it_behaves_like 'an Entity subclass' do
    let(:klass) { Entities::SignedRetraction }
  end
end
