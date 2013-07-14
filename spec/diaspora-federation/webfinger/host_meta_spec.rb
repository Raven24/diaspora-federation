require 'spec_helper'

describe WebFinger::HostMeta do
  let(:base_url) { 'https://pod.example.tld/' }
  let(:xml) { <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Link rel="lrdd" type="application/xrd+xml" template="#{base_url}webfinger?q={uri}"/>
</XRD>
XML
  }

  let(:historic_xml) { <<-XML
<?xml version='1.0' encoding='UTF-8'?>
<XRD xmlns='http://docs.oasis-open.org/ns/xri/xrd-1.0'>

  <!-- Resource-specific Information -->

  <Link rel='lrdd'
        type='application/xrd+xml'
        template='#{base_url}webfinger?q={uri}' />

</XRD>
XML
  }

  let(:invalid_xml) { <<XML
<?xml version='1.0' encoding='UTF-8'?>
<XRD xmlns='http://docs.oasis-open.org/ns/xri/xrd-1.0'>
</XRD>
XML
  }

  context '#to_xml' do
    it 'creates a nice XML document' do
      hm = WebFinger::HostMeta.new
      hm.webfinger_base_url = base_url

      hm.to_xml.should eql(xml)
    end

    it 'appends a "/" if necessary' do
      hm = WebFinger::HostMeta.new
      hm.webfinger_base_url = 'https://pod.example.tld'

      hm.to_xml.should eql(xml)
    end

    it 'fails if the webfinger_base_url was omitted' do
      hm = WebFinger::HostMeta.new
      expect { hm.to_xml }.to raise_error(WebFinger::HostMeta::InsufficientData)
    end
  end

  context '#webfinger_url' do
    it 'parses its own output' do
      h = WebFinger::HostMeta.from_xml(xml)
      h.webfinger_url.should eql("#{base_url}webfinger?q={uri}")
    end

    it 'also reads old-style XML' do
      h = WebFinger::HostMeta.from_xml(historic_xml)
      h.webfinger_url.should eql("#{base_url}webfinger?q={uri}")
    end

    it 'fails if the document does not contain a webfinger url' do
      h = WebFinger::HostMeta.from_xml(invalid_xml)
      expect { h.webfinger_url }.to raise_error(WebFinger::HostMeta::InsufficientData)
    end

    it 'fails if no document was parsed before' do
      h = WebFinger::HostMeta.new
      expect { h.webfinger_url }.to raise_error(WebFinger::HostMeta::ImproperInvocation)
    end
  end
end
