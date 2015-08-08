require 'spec_helper'

describe Entities::Profile do
  let(:data) { Fabricate.attributes_for(:profile) }

  let(:xml) do
    <<-XML
<profile>
  <diaspora_handle>#{data[:diaspora_handle]}</diaspora_handle>
  <first_name>#{data[:first_name]}</first_name>
  <last_name/>
  <image_url>#{data[:image_url]}</image_url>
  <image_url_medium/>
  <image_url_small/>
  <birthday>#{data[:birthday]}</birthday>
  <gender>#{data[:gender]}</gender>
  <bio>#{data[:bio]}</bio>
  <location>#{data[:location]}</location>
  <searchable>#{data[:searchable]}</searchable>
  <nsfw>#{data[:nsfw]}</nsfw>
  <tag_string>#{data[:tag_string]}</tag_string>
</profile>
XML
  end

  it_behaves_like 'an Entity subclass' do
    let(:klass) { Entities::Profile }
  end
end
