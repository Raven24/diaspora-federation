require 'spec_helper'

describe Entities::Post do
  before do
    @datetime = DateTime.now
  end

  let(:data) { {guid: '0123456798abcdef',
                diaspora_handle: 'alice@somepod.org',
                public: true,
                created_at: @datetime,
                provider_display_name: 'mobile'} }

  let(:xml) { <<-XML

<post>
  <guid>0123456798abcdef</guid>
  <diaspora_handle>alice@somepod.org</diaspora_handle>
  <public>true</public>
  <created_at>#{@datetime}</created_at>
  <provider_display_name>mobile</provider_display_name>
</post>
XML
  }

  it_behaves_like "an Entity subclass" do
    let(:klass) { Entities::Post }
  end
end
