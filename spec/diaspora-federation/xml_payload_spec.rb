require 'spec_helper'

describe XmlPayload do
  let(:entity) { Entities::TestEntity.new(test: 'asdf') }
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
      xml.should be_an_instance_of Nokogiri::XML::Element
      xml.name.should eql('XML')
      xml.children.should have(1).item
      xml.children[0].name.should eql('post')
      xml.children[0].children.should have(1).item
    end

    it 'returns the entity xml inside the wrapper' do
      xml = XmlPayload.pack(entity)
      xml.children[0].children[0].name.should eql('test_entity')
      xml.children[0].children[0].children.should have(1).item
    end

    it 'produces the expected XML' do
      XmlPayload.pack(entity).to_xml.should eql(xml_str.strip)
    end
  end

  context '::unpack' do
    context 'sanity' do
      it 'expects an Nokogiri::XML::Element as param' do
        expect {
          XmlPayload.unpack(payload)
        }.not_to raise_error
      end

      it 'raises and error when the param is not an Nokogiri::XML::Element' do
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
          XmlPayload.unpack(Nokogiri::XML::Document.parse(xml).root)
        }.to raise_error XmlPayload::InvalidStructure
      end
    end

    context 'returned object' do
      subject { XmlPayload.unpack(payload) }

      its(:to_h) { should eql(entity.to_h) }

      it 'returns an entity instance of the original class' do
        subject.should be_an_instance_of Entities::TestEntity
        subject.test.should eql('asdf')
      end
    end

    context 'nested entities' do
      let(:child_entity1) { Entities::TestEntity.new({test: 'bla'}) }
      let(:child_entity2) { Entities::OtherEntity.new({asdf: 'blabla'}) }
      let(:nested_entity) {
        Entities::TestNestedEntity.new({asdf: 'QWERT',
                                        test: child_entity1,
                                        multi: [child_entity2, child_entity2]})
      }
      let(:nested_payload) { XmlPayload.pack(nested_entity) }

      it 'parses the xml with all the nested data' do
        e = XmlPayload.unpack(nested_payload)
        e.test.to_h.should eql(child_entity1.to_h)
        e.multi.should have(2).items
        e.multi.first.to_h.should eql(child_entity2.to_h)
        e.asdf.should eql('QWERT')
      end
    end
  end
end
