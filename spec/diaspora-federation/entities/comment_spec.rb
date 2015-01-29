require 'spec_helper'

describe Entities::Comment do
  let(:data) do
    { guid: '0123456789abcdef',
      parent_guid: 'fedcba987654321',
      parent_author_signature: 'BBBBBB==',
      author_signature: 'AAAAAA==',
      text: 'my comment text',
      diaspora_handle: 'bob@pod.somedomain.tld' }
  end

  let(:xml) do
    <<-XML
<comment>
  <guid>0123456789abcdef</guid>
  <parent_guid>fedcba987654321</parent_guid>
  <parent_author_signature>BBBBBB==</parent_author_signature>
  <author_signature>AAAAAA==</author_signature>
  <text>my comment text</text>
  <diaspora_handle>bob@pod.somedomain.tld</diaspora_handle>
</comment>
XML
  end

  it_behaves_like 'an Entity subclass' do
    let(:klass) { Entities::Comment }
  end
end
