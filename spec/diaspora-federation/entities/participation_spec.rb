require 'spec_helper'

describe Entities::Participation do
  let(:data) do
    { guid: '0123456789abcdef',
      target_type: 'Post',
      parent_guid: 'fedcba9876543210',
      parent_author_signature: 'BBBBBB==',
      author_signature: 'AAAAAA==',
      diaspora_handle: 'luke@diaspora.example.tld' }
  end

  let(:xml) do
    <<-XML
<participation>
  <guid>0123456789abcdef</guid>
  <target_type>Post</target_type>
  <parent_guid>fedcba9876543210</parent_guid>
  <parent_author_signature>BBBBBB==</parent_author_signature>
  <author_signature>AAAAAA==</author_signature>
  <diaspora_handle>luke@diaspora.example.tld</diaspora_handle>
</participation>
XML
  end

  it_behaves_like 'an Entity subclass' do
    let(:klass) { Entities::Participation }
  end
end
