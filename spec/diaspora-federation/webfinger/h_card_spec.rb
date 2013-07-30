require 'spec_helper'

describe WebFinger::HCard do
  let(:guid) { Fabricate.sequence(:guid) }
  let(:handle) { Fabricate.sequence(:diaspora_handle) }
  let(:first_name) { 'Test' }
  let(:last_name)  { 'Testington' }
  let(:name) { "#{first_name} #{last_name}" }
  let(:url) { 'https://pod.example.tld/users/me' }
  let(:photo_url) { 'https://pod.example.tld/uploads/f.jpg' }
  let(:photo_url_m) { 'https://pod.example.tld/uploads/m.jpg' }
  let(:photo_url_s) { 'https://pod.example.tld/uploads/s.jpg' }
  let(:key) { 'ABCDEF==' }
  let(:searchable) { true }

  let(:html) { <<-HTML

<!DOCTYPE html >
<html>
  <head>
    <meta charset="UTF-8"/>
    <title>#{name}</title>
  </head>
  <body>
    <div id="content">
      <h1>#{name}</h1>
      <div id="content_inner" class="entity_profile vcard author">
        <dl class="entity_uid">
          <dt>Uid</dt>
          <dd>
            <span class="uid">#{guid}</span>
          </dd>
        </dl>
        <dl class="entity_nickname">
          <dt>Nickname</dt>
          <dd>
            <span class="nickname">#{handle.split('@').first}</span>
          </dd>
        </dl>
        <dl class="entity_full_name">
          <dt>Full_name</dt>
          <dd>
            <span class="fn">#{name}</span>
          </dd>
        </dl>
        <dl class="entity_searchable">
          <dt>Searchable</dt>
          <dd>
            <span class="searchable">#{searchable}</span>
          </dd>
        </dl>
        <dl class="entity_key">
          <dt>Key</dt>
          <dd>
            <span class="key">#{key}</span>
          </dd>
        </dl>
        <dl class="entity_first_name">
          <dt>First_name</dt>
          <dd>
            <span class="given_name">#{first_name}</span>
          </dd>
        </dl>
        <dl class="entity_family_name">
          <dt>Family_name</dt>
          <dd>
            <span class="family_name">#{last_name}</span>
          </dd>
        </dl>
        <dl class="entity_url">
          <dt>Url</dt>
          <dd>
            <a id="pod_location" class="url" rel="me" href="#{url}">#{url}</a>
          </dd>
        </dl>
        <dl class="entity_photo">
          <dt>Photo</dt>
          <dd>
            <img class="photo avatar" width="300px" height="300px" src="#{photo_url}"/>
          </dd>
        </dl>
        <dl class="entity_photo_medium">
          <dt>Photo_medium</dt>
          <dd>
            <img class="photo avatar" width="100px" height="100px" src="#{photo_url_m}"/>
          </dd>
        </dl>
        <dl class="entity_photo_small">
          <dt>Photo_small</dt>
          <dd>
            <img class="photo avatar" width="50px" height="50px" src="#{photo_url_s}"/>
          </dd>
        </dl>
      </div>
    </div>
  </body>
</html>
HTML
  }

  let(:historic_html) { <<-HTML
<div id='content'>
<h1>#{name}</h1>
<div id='content_inner'>
<div class='entity_profile vcard author' id='i'>
<h2>User profile</h2>
<dl class='entity_nickname'>
<dt>Nickname</dt>
<dd>
<a class='nickname url uid' href='#{url}' rel='me'>#{name}</a>
</dd>
</dl>
<dl class='entity_given_name'>
<dt>First name</dt>
<dd>
<span class='given_name'>#{first_name}</span>
</dd>
</dl>
<dl class='entity_family_name'>
<dt>Family name</dt>
<dd>
<span class='family_name'>#{last_name}</span>
</dd>
</dl>
<dl class='entity_fn'>
<dt>Full name</dt>
<dd>
<span class='fn'>#{name}</span>
</dd>
</dl>
<dl class='entity_url'>
<dt>URL</dt>
<dd>
<a class='url' href='#{url}' id='pod_location' rel='me'>#{url}</a>
</dd>
</dl>
<dl class='entity_photo'>
<dt>Photo</dt>
<dd>
<img class='photo avatar' height='300px' src='#{photo_url}' width='300px'>
</dd>
</dl>
<dl class='entity_photo_medium'>
<dt>Photo</dt>
<dd>
<img class='photo avatar' height='100px' src='#{photo_url_m}' width='100px'>
</dd>
</dl>
<dl class='entity_photo_small'>
<dt>Photo</dt>
<dd>
<img class='photo avatar' height='50px' src='#{photo_url_s}' width='50px'>
</dd>
</dl>
<dl class='entity_searchable'>
<dt>Searchable</dt>
<dd>
<span class='searchable'>#{searchable}</span>
</dd>
</dl>
</div>
</div>
</div>
HTML
  }

  let(:invalid_html) { <<-HTML
<div id="content">
  <span class='fn'>#{name}</span>
</div>
HTML
  }

  context 'generation' do
    it 'creates an instance from a data hash' do
      hc = WebFinger::HCard.from_account({
        guid: guid,
        diaspora_handle: handle,
        full_name: name,
        url: url,
        photo_full_url: photo_url,
        photo_medium_url: photo_url_m,
        photo_small_url: photo_url_s,
        pubkey: key,
        searchable: searchable,
        first_name: first_name,
        last_name: last_name
      })
      hc.to_html.should eql(html)
    end

    it 'fails if some params are missing' do
      expect {
        WebFinger::HCard.from_account({
          guid: guid,
          diaspora_handle: handle
        })
      }.to raise_error(WebFinger::HCard::InvalidData)
    end

    it 'fails if nothing was given' do
      expect { WebFinger::HCard.from_account({}) }.to raise_error(WebFinger::HCard::InvalidData)
    end
  end

  context 'parsing' do
    it 'reads its own output' do
      hc = WebFinger::HCard.from_html(html)
      hc.guid.should eql(guid)
      hc.nickname.should eql(handle.split('@').first)
      hc.full_name.should eql(name)
      hc.url.should eql(url)
      hc.photo_full_url.should eql(photo_url)
      hc.photo_medium_url.should eql(photo_url_m)
      hc.photo_small_url.should eql(photo_url_s)
      hc.pubkey.should eql(key)
      hc.searchable.should eql(searchable.to_s)

      hc.first_name.should eql(first_name)
      hc.last_name.should eql(last_name)
    end

    it 'reads old-style HTML' do
      hc = WebFinger::HCard.from_html(historic_html)
      hc.url.should eql(url)
      hc.photo_full_url.should eql(photo_url)
      hc.photo_medium_url.should eql(photo_url_m)
      hc.photo_small_url.should eql(photo_url_s)
      hc.searchable.should eql(searchable.to_s)

      hc.first_name.should eql(first_name)
      hc.last_name.should eql(last_name)
    end

    it 'fails if the document is incomplete' do
      expect { WebFinger::HCard.from_html(invalid_html) }.to raise_error(WebFinger::HCard::InvalidData)
    end

    it 'fails if the document is not HTML' do
      expect { WebFinger::HCard.from_html('') }.to raise_error
    end
  end
end
