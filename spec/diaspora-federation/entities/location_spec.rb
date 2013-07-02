require 'spec_helper'

describe Entities::Location do
  let(:data) { {address: 'Vienna, Austria',
                lat: 48.208174,
                lng: 16.373819} }

  let(:xml) { <<-XML

<location>
  <address>Vienna, Austria</address>
  <lat>48.208174</lat>
  <lng>16.373819</lng>
</location>
XML
  }

  it_behaves_like "an Entity subclass" do
    let(:klass) { Entities::Location }
  end
end
