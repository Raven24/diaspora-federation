require 'spec_helper'

describe Entities::Person do
  let(:profile) { Entities::Profile.new(Fabricate.attributes_for(:profile)) }
  let(:data) do
    { guid: Fabricate.sequence(:guid),
      diaspora_handle: Fabricate.sequence(:diaspora_handle),
      url: 'https://d.example.tld/',
      profile: profile,
      exported_key: "-----BEGIN RSA PUBLIC KEY-----\nAAAAAA==\n-----END RSA PUBLIC KEY-----\n" }
  end

  let(:xml) do
    <<-XML
<person>
  <guid>#{data[:guid]}</guid>
  <diaspora_handle>#{data[:diaspora_handle]}</diaspora_handle>
  <url>#{data[:url]}</url>
  <profile>
    <diaspora_handle>#{profile.diaspora_handle}</diaspora_handle>
    <first_name>#{profile.first_name}</first_name>
    <last_name/>
    <image_url>#{profile.image_url}</image_url>
    <image_url_medium/>
    <image_url_small/>
    <birthday>#{profile.birthday}</birthday>
    <gender>#{profile.gender}</gender>
    <bio>#{profile.bio}</bio>
    <location>#{profile.location}</location>
    <searchable>#{profile.searchable}</searchable>
    <nsfw>#{profile.nsfw}</nsfw>
    <tag_string>#{profile.tag_string}</tag_string>
  </profile>
  <exported_key>#{data[:exported_key]}</exported_key>
</person>
XML
  end

  it_behaves_like 'an Entity subclass' do
    let(:klass) { Entities::Person }
  end
end
