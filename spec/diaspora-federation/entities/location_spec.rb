require 'spec_helper'

describe Entities::Location do
  let(:data) { Fabricate.attributes_for(:location) }

  let(:xml) { <<-XML

<location>
  <address>#{data[:address]}</address>
  <lat>#{data[:lat]}</lat>
  <lng>#{data[:lng]}</lng>
</location>
XML
  }

  it_behaves_like "an Entity subclass" do
    let(:klass) { Entities::Location }
  end
end
