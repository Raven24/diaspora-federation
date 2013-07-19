require 'spec_helper'

describe WebFinger::WebFinger do
  let(:acct) { 'acct:user@pod.example.tld' }
  let(:alias_url)   { 'http://pod.example.tld/' }
  let(:hcard_url)   { 'https://pod.example.tld/hcard/users/abcdef0123456789' }
  let(:seed_url)    { 'https://pod.geraspora.de/' }
  let(:guid)        { 'abcdef0123456789' }
  let(:profile_url) { 'https://pod.example.tld/u/user' }
  let(:updates_url) { 'https://pod.example.tld/public/user.atom' }
  let(:pubkey) { 'AAAAAA==' }

  let(:xml) { <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Subject>#{acct}</Subject>
  <Alias>#{alias_url}</Alias>
  <Link rel="http://microformats.org/profile/hcard" type="text/html" href="#{hcard_url}"/>
  <Link rel="http://joindiaspora.com/seed_location" type="text/html" href="#{seed_url}"/>
  <Link rel="http://joindiaspora.com/guid" type="text/html" href="#{guid}"/>
  <Link rel="http://webfinger.net/rel/profile-page" type="text/html" href="#{profile_url}"/>
  <Link rel="http://schemas.google.com/g/2010#updates-from" type="application/atom+xml" href="#{updates_url}"/>
  <Link rel="diaspora-public-key" type="RSA" href="#{pubkey}"/>
</XRD>
XML
  }

  let(:historic_xml) { <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Subject>#{acct}</Subject>
  <Alias>#{alias_url}</Alias>
  <Link rel="http://microformats.org/profile/hcard" type="text/html" href="#{hcard_url}"/>
  <Link rel="http://joindiaspora.com/seed_location" type = 'text/html' href="#{seed_url}"/>
  <Link rel="http://joindiaspora.com/guid" type = 'text/html' href="#{guid}"/>

  <Link rel='http://webfinger.net/rel/profile-page' type='text/html' href="#{profile_url}"/>
  <Link rel="http://schemas.google.com/g/2010#updates-from" type="application/atom+xml" href="#{updates_url}"/>

  <Link rel="diaspora-public-key" type = 'RSA' href="#{pubkey}"/>
</XRD>
XML
  }

  let(:invalid_xml) { <<XML
<?xml version='1.0' encoding='UTF-8'?>
<XRD xmlns='http://docs.oasis-open.org/ns/xri/xrd-1.0'>
</XRD>
XML
  }

  it 'must not create blank instances' do
    expect { WebFinger::WebFinger.new }.to raise_error
  end

  context 'generation' do
    it 'creates a nice XML document' do
      wf = WebFinger::WebFinger.from_account({
        acct_uri: acct,
        alias_url: alias_url,
        hcard_url: hcard_url,
        seed_url: seed_url,
        profile_url: profile_url,
        updates_url: updates_url,
        guid: guid,
        pubkey: pubkey
      })
      wf.to_xml.should eql(xml)
    end

    it 'fails if some params are missing' do
      expect {
        WebFinger::WebFinger.from_account({
          acct_uri: acct,
          alias_url: alias_url,
          hcard_url: hcard_url
        })
      }.to raise_error(WebFinger::WebFinger::InvalidData)
    end

    it 'fails if nothing was given' do
      expect { WebFinger::WebFinger.from_account({}) }.to raise_error(WebFinger::WebFinger::InvalidData)
    end
  end

  context 'parsing' do
    it 'reads its own output' do
      wf = WebFinger::WebFinger.from_xml(xml)
      wf.acct_uri.should eql(acct)
      wf.alias_url.should eql(alias_url)
      wf.hcard_url.should eql(hcard_url)
      wf.seed_url.should eql(seed_url)
      wf.profile_url.should eql(profile_url)
      wf.updates_url.should eql(updates_url)

      wf.guid.should eql(guid)
      wf.pubkey.should eql(pubkey)
    end

    it 'reads old-style XML' do
      wf = WebFinger::WebFinger.from_xml(historic_xml)
      wf.acct_uri.should eql(acct)
      wf.alias_url.should eql(alias_url)
      wf.hcard_url.should eql(hcard_url)
      wf.seed_url.should eql(seed_url)
      wf.profile_url.should eql(profile_url)
      wf.updates_url.should eql(updates_url)

      wf.guid.should eql(guid)
      wf.pubkey.should eql(pubkey)
    end

    it 'fails if the document is empty' do
      expect { WebFinger::WebFinger.from_xml(invalid_xml) }.to raise_error(WebFinger::WebFinger::InvalidData)
    end

    it 'fails if the document is not XML' do
      expect { WebFinger::WebFinger.from_xml('') }.to raise_error(WebFinger::XrdDocument::InvalidDocument)
    end
  end
end
