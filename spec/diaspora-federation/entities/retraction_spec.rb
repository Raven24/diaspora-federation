require 'spec_helper'

describe Entities::Retraction do
  let(:data) do
    { post_guid: '0123456789abcdef',
      diaspora_handle: 'luke@diaspora.example.tld',
      type: 'StatusMessage' }
  end

  let(:xml) do
    <<-XML
<retraction>
  <post_guid>0123456789abcdef</post_guid>
  <diaspora_handle>luke@diaspora.example.tld</diaspora_handle>
  <type>StatusMessage</type>
</retraction>
XML
  end

  it_behaves_like 'an Entity subclass' do
    let(:klass) { Entities::Retraction }
  end
end
