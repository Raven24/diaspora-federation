require 'spec_helper'

describe Salmon::Slap do
  let(:author_id) { 'test_user@pod.somedomain.tld' }
  let(:pkey) { OpenSSL::PKey::RSA.generate(512) } # use small key for speedy specs
  let(:entity) { Entities::TestEntity.new(test: 'qwertzuiop') }
  let(:slap) { Salmon::Slap.generate_xml(author_id, pkey, entity) }

  context '::generate_xml' do
    context 'sanity' do
      it 'accepts correct params' do
        expect { Salmon::Slap.generate_xml(author_id, pkey, entity) }.not_to raise_error
      end

      it 'raises an error when the params are the wrong type' do
        ['asdf', 12_345, true, :symbol, entity, pkey].each do |val|
          expect { Salmon::Slap.generate_xml(val, val, val) }.to raise_error
        end
      end
    end

    it 'generates valid xml' do
      ns = { 'd' => DiasporaFederation::XMLNS, 'me' => Salmon::MagicEnvelope::XMLNS }
      doc = Nokogiri::XML::Document.parse(slap)
      expect(doc.root.name).to eql('diaspora')
      expect(doc.at_xpath('d:diaspora/d:header/d:author_id', ns).content).to eql(author_id)
      expect(doc.xpath('d:diaspora/me:env', ns).length).to eq(1)
    end
  end

  context '::from_xml' do
    context 'sanity' do
      it 'accepts salmon xml as param' do
        expect { Salmon::Slap.from_xml(slap) }.not_to raise_error
      end

      it 'raises an error when the param has a wrong type' do
        [12_345, false, :symbol, entity, pkey].each do |val|
          expect { Salmon::Slap.from_xml(val) }.to raise_error
        end
      end

      it 'verifies the existence of an author_id' do
        faulty_xml = <<XML
<diaspora>
  <header/>
</diaspora>
XML
        expect do
          Salmon::Slap.from_xml(faulty_xml)
        end.to raise_error Salmon::Slap::MissingAuthor
      end

      it 'verifies the existence of a magic envelope' do
        faulty_xml = <<-XML
<diaspora>
  <header>
    <author_id>#{author_id}</author_id>
  </header>
</diaspora>
XML
        expect do
          Salmon::Slap.from_xml(faulty_xml)
        end.to raise_error Salmon::MissingMagicEnvelope
      end
    end
  end

  context 'generated instance' do
    it_behaves_like 'a Slap instance' do
      subject { Salmon::Slap.from_xml(slap) }
    end
  end
end
