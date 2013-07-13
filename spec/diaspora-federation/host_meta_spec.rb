require 'spec_helper'

describe HostMeta do
  let(:data) { {rel: 'lrdd',
                type: 'application/xrd+xml',
                template: 'https://pod.example.tld/webfinger?q={uri}'} }
  let(:xml) { <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Link rel="lrdd" type="application/xrd+xml" template="https://pod.example.tld/webfinger?q={uri}"/>
</XRD>
XML
  }

  let(:historic_xml) { <<-XML
<?xml version='1.0' encoding='UTF-8'?>
<XRD xmlns='http://docs.oasis-open.org/ns/xri/xrd-1.0'>

  <!-- Resource-specific Information -->

  <Link rel='#{data[:rel]}'
        type='#{data[:type]}'
        template='#{data[:template]}' />

</XRD>
XML
  }

  it 'creates a nice XML document' do
    hm = HostMeta.new
    hm.links << data

    hm.to_xml.should eql(xml)
  end

  it 'parses its own output' do
    h = HostMeta.xml_data(xml)
    h.should eql({links: [data]})
  end

  it 'also reads old-style XML' do
    h = HostMeta.xml_data(historic_xml)
    h.should eql({links: [data]})
  end
end
