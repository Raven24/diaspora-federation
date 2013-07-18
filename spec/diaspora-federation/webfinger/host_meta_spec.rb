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
      hm = WebFinger::HostMeta.from_base_url(base_url)
      hm.to_xml.should eql(xml)
    end

    it 'appends a "/" if necessary' do
      hm = WebFinger::HostMeta.from_base_url('https://pod.example.tld')
      hm.to_xml.should eql(xml)
    end

    it 'fails if the base_url was omitted' do
      expect { WebFinger::HostMeta.from_base_url('') }.to raise_error(WebFinger::HostMeta::InvalidData)
    end
  end

  context '#webfinger_url' do
    it 'parses its own output' do
      h = WebFinger::HostMeta.from_xml(xml)
      h.webfinger_template_url.should eql("#{base_url}webfinger?q={uri}")
    end

    it 'also reads old-style XML' do
      h = WebFinger::HostMeta.from_xml(historic_xml)
      h.webfinger_template_url.should eql("#{base_url}webfinger?q={uri}")
    end

    it 'fails if the document does not contain a webfinger url' do
      expect { WebFinger::HostMeta.from_xml(invalid_xml) }.to raise_error(WebFinger::HostMeta::InvalidData)
    end

    it 'fails if the document is invalid' do
      expect { WebFinger::HostMeta.from_xml('') }.to raise_error(WebFinger::XrdDocument::InvalidDocument)
    end
  end
end
