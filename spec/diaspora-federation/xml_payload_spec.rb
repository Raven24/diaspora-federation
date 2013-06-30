require 'spec_helper'

class TestEntity < Entity
  set_allowed_props :test
end

describe XmlPayload do
  let(:entity) { TestEntity.new(test: 'asdf') }
  let(:payload) { XmlPayload.pack(entity) }

  let(:xml_str) { <<XML

<XML>
  <post>
    <test_entity>
      <test>asdf</test>
    </test_entity>
  </post>
</XML>
XML
  }

  context '::pack' do
    it 'expects an Entity as param' do
      expect {
        XmlPayload.pack(entity)
      }.not_to raise_error
    end

    it 'raises an error when the param is not an Entity' do
      ['asdf', 1234, true, :test, payload].each do |val|
        expect {
          XmlPayload.pack(val)
        }.to raise_error
      end
    end

    it 'returns an xml wrapper' do
      xml = XmlPayload.pack(entity)
      xml.should be_an_instance_of Ox::Element
      xml.name.should eql('XML')
      xml.nodes.should have(1).item
      xml.nodes[0].name.should eql('post')
      xml.nodes[0].nodes.should have(1).item
    end

    it 'returns the entity xml inside the wrapper' do
      xml = XmlPayload.pack(entity)
      xml.nodes[0].nodes[0].name.should eql('test_entity')
      xml.nodes[0].nodes[0].nodes.should have(1).item
    end

    it 'produces the expected XML' do
      Ox.dump(XmlPayload.pack(entity)).should eql(xml_str)
    end
  end

  context '::unpack' do
    context 'sanity' do
      it 'expects an Ox::Element as param' do
        expect {
          XmlPayload.unpack(payload)
        }.not_to raise_error
      end

      it 'raises and error when the param is not an Ox::Element' do
        ['asdf', 1234, true, :test, entity].each do |val|
          expect {
            XmlPayload.unpack(val)
          }.to raise_error
        end
      end

      it 'raises an error when the xml is wrong' do
        xml = <<XML
<root>
  <weird/>
</root>
XML
        expect {
          XmlPayload.unpack(Ox.parse(xml))
        }.to raise_error XmlPayload::InvalidStructure
      end
    end

    context 'returned object' do
      subject { XmlPayload.unpack(payload) }

      its(:to_h) { should eql(entity.to_h) }

      it 'returns an entity instance of the original class' do
        subject.should be_an_instance_of TestEntity
      end
    end
  end
end
