require 'spec_helper'

describe Entities::Photo do

  let(:data) { Fabricate.attributes_for(:photo) }

  let(:xml) { <<-XML

<photo>
  <guid>#{data[:guid]}</guid>
  <diaspora_handle>#{data[:diaspora_handle]}</diaspora_handle>
  <public>#{data[:public]}</public>
  <created_at>#{data[:created_at]}</created_at>
  <remote_photo_path>#{data[:remote_photo_path]}</remote_photo_path>
  <remote_photo_name>#{data[:remote_photo_name]}</remote_photo_name>
  <text>#{data[:text]}</text>
  <status_message_guid>#{data[:status_message_guid]}</status_message_guid>
  <height>#{data[:height]}</height>
  <width>#{data[:width]}</width>
</photo>
XML
  }

  it_behaves_like "an Entity subclass" do
    let(:klass) { Entities::Photo }
  end
end
