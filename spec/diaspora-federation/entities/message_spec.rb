require 'spec_helper'

describe Entities::Message do
  let(:data) { Fabricate.attributes_for(:message) }

  let(:xml) { <<-XML

<message>
  <guid>#{data[:guid]}</guid>
  <parent_guid>#{data[:parent_guid]}</parent_guid>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
  <author_signature>#{data[:author_signature]}</author_signature>
  <text>#{data[:text]}</text>
  <created_at>#{data[:created_at]}</created_at>
  <diaspora_handle>#{data[:diaspora_handle]}</diaspora_handle>
  <conversation_guid>#{data[:conversation_guid]}</conversation_guid>
</message>
XML
  }

  it_behaves_like "an Entity subclass" do
    let(:klass) { Entities::Message }
  end
end
