require 'spec_helper'

describe Entities::Request do
  let(:data) { {sender_handle: 'alice@somepod.org',
                recipient_handle: 'bob@otherpod.net'} }

  let(:xml) { <<-XML

<request>
  <sender_handle>alice@somepod.org</sender_handle>
  <recipient_handle>bob@otherpod.net</recipient_handle>
</request>
XML
  }

  it_behaves_like "an Entity subclass" do
    let(:klass) { Entities::Request }
  end
end
