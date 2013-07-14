require 'spec_helper'

describe WebFinger::XrdDocument do
  let(:xml) { <<XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Expires>2010-01-30T09:30:00Z</Expires>
  <Subject>http://blog.example.com/article/id/314</Subject>
  <Alias>http://blog.example.com/cool_new_thing</Alias>
  <Alias>http://blog.example.com/steve/article/7</Alias>
  <Property type="http://blgx.example.net/ns/version">1.3</Property>
  <Property type="http://blgx.example.net/ns/ext"/>
  <Link rel="author" type="text/html" href="http://blog.example.com/author/steve"/>
  <Link rel="author" href="http://example.com/author/john"/>
  <Link rel="copyright" template="http://example.com/copyright?id={uri}"/>
</XRD>
XML
  }

  let(:data) { {
    subject: "http://blog.example.com/article/id/314",
    expires: DateTime.parse("2010-01-30T09:30:00Z"),
    aliases: [
      "http://blog.example.com/cool_new_thing",
      "http://blog.example.com/steve/article/7"
    ],
    properties: {
      "http://blgx.example.net/ns/version" => "1.3",
      "http://blgx.example.net/ns/ext" => nil
    },
    links: [
      {
        rel: "author",
        type: "text/html",
        href: "http://blog.example.com/author/steve"
      },
      {
        rel: "author",
        href: "http://example.com/author/john"
      },
      {
        rel: "copyright",
        template: "http://example.com/copyright?id={uri}"
      }
    ]
  } }

  let(:doc) {
    d = WebFinger::XrdDocument.new
    d.expires = data[:expires]
    d.subject = data[:subject]

    data[:aliases].each do |a|
      d.aliases << a
    end

    data[:properties].each do |t, v|
      d.properties[t] = v
    end

    data[:links].each do |h|
      d.links << h
    end

    d
  }

  it 'creates the xml document' do
    doc.to_xml.should eql(xml)
  end

  it 'reads the xml document' do
    d = WebFinger::XrdDocument.xml_data(xml)
    d.should eql(data)
  end
end
