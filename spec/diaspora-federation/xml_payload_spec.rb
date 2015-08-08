require 'spec_helper'

describe XmlPayload do
  let(:entity) { Entities::TestEntity.new(test: 'asdf') }
  let(:payload) { XmlPayload.pack(entity) }

  let(:xml_str) do
    <<XML
<XML>
  <post>
    <test_entity>
      <test>asdf</test>
    </test_entity>
  </post>
</XML>
XML
  end

  context '::pack' do
    it 'expects an Entity as param' do
      expect do
        XmlPayload.pack(entity)
      end.not_to raise_error
    end

    it 'raises an error when the param is not an Entity' do
      ['asdf', 1234, true, :test, payload].each do |val|
        expect do
          XmlPayload.pack(val)
        end.to raise_error
      end
    end

    it 'returns an xml wrapper' do
      xml = XmlPayload.pack(entity)
      expect(xml).to be_an_instance_of Nokogiri::XML::Element
      expect(xml.name).to eql('XML')
      expect(xml.children.length).to eq(1)
      expect(xml.children[0].name).to eql('post')
      expect(xml.children[0].children.length).to eq(1)
    end

    it 'returns the entity xml inside the wrapper' do
      xml = XmlPayload.pack(entity)
      expect(xml.children[0].children[0].name).to eql('test_entity')
      expect(xml.children[0].children[0].children.length).to eq(1)
    end

    it 'produces the expected XML' do
      expect(XmlPayload.pack(entity).to_xml).to eql(xml_str.strip)
    end
  end

  context '::unpack' do
    context 'sanity' do
      it 'expects an Nokogiri::XML::Element as param' do
        expect do
          XmlPayload.unpack(payload)
        end.not_to raise_error
      end

      it 'raises and error when the param is not an Nokogiri::XML::Element' do
        ['asdf', 1234, true, :test, entity].each do |val|
          expect do
            XmlPayload.unpack(val)
          end.to raise_error
        end
      end

      it 'raises an error when the xml is wrong' do
        xml = <<XML
<root>
  <weird/>
</root>
XML
        expect do
          XmlPayload.unpack(Nokogiri::XML::Document.parse(xml).root)
        end.to raise_error XmlPayload::InvalidStructure
      end
    end

    context 'returned object' do
      subject { XmlPayload.unpack(payload) }

      it { expect(subject.to_h).to eql(entity.to_h) }

      it 'returns an entity instance of the original class' do
        expect(subject).to be_an_instance_of Entities::TestEntity
        expect(subject.test).to eql('asdf')
      end
    end

    context 'nested entities' do
      let(:child_entity1) { Entities::TestEntity.new(test: 'bla') }
      let(:child_entity2) { Entities::OtherEntity.new(asdf: 'blabla') }
      let(:nested_entity) do
        Entities::TestNestedEntity.new(asdf: 'QWERT',
                                       test: child_entity1,
                                       multi: [child_entity2, child_entity2])
      end
      let(:nested_payload) { XmlPayload.pack(nested_entity) }

      it 'parses the xml with all the nested data' do
        e = XmlPayload.unpack(nested_payload)
        expect(e.test.to_h).to eql(child_entity1.to_h)
        expect(e.multi.length).to eq(2)
        expect(e.multi.first.to_h).to eql(child_entity2.to_h)
        expect(e.asdf).to eql('QWERT')
      end
    end
  end
end
