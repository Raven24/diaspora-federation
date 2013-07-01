require 'spec_helper'

describe Salmon::Slap do
  let(:author_id) { 'test_user@pod.somedomain.tld' }
  let(:pkey) { OpenSSL::PKey::RSA.generate(512) } # use small key for speedy specs
  let(:entity) { Entities::TestEntity.new(test: 'qwertzuiop') }
  let(:slap) { Salmon::Slap.to_xml(author_id, pkey, entity) }

  context '::to_xml' do
    context 'sanity' do
      it 'accepts correct params' do
        expect { Salmon::Slap.to_xml(author_id, pkey, entity) }.not_to raise_error
      end

      it 'raises an error when the params are the wrong type' do
        ['asdf', 12345, true, :symbol, entity, pkey].each do |val|
          expect { Salmon::Slap.to_xml(val, val, val) }.to raise_error
        end
      end
    end

    it 'generates valid xml' do
      doc = Ox.parse(slap)
      doc.locate('diaspora').should have(1).item
      doc.diaspora.header.author_id.text.should eql(author_id)
      doc.locate('diaspora/me:env').should have(1).item
    end
  end

  context '::from_xml' do
    context 'sanity' do
      it 'accepts salmon xml as param' do
        expect { Salmon::Slap.from_xml(slap) }.not_to raise_error
      end

      it 'raises an error when the param has a wrong type' do
        [12345, false, :symbol, entity, pkey].each do |val|
          expect { Salmon::Slap.from_xml(val) }.to raise_error
        end
      end

      it 'verifies the existence of an author_id' do
        faulty_xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<diaspora>
  <header/>
</diaspora>
XML
        expect {
          Salmon::Slap.from_xml(faulty_xml)
        }.to raise_error Salmon::Slap::MissingAuthor
      end

      it 'verifies the existence of a magic envelope' do
        faulty_xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<diaspora>
  <header>
    <author_id>#{author_id}</author_id>
  </header>
</diaspora>
XML
        expect {
          Salmon::Slap.from_xml(faulty_xml)
        }.to raise_error Salmon::Slap::MissingMagicEnvelope
      end
    end
  end

  context 'instance' do
    subject { Salmon::Slap.from_xml(slap) }

    its(:author_id) { should eql(author_id) }

    context '#entity' do
      it 'requires the pubkey for the first time (to verify the signature)' do
        expect { subject.entity }.to raise_error
      end

      it 'works when the pubkey is given' do
        expect {
          subject.entity(pkey.public_key)
        }.not_to raise_error
      end

      it 'returns the entity' do
        e = subject.entity(pkey.public_key)
        e.should be_an_instance_of Entities::TestEntity
        e.test.should eql('qwertzuiop')
      end

      it 'does not require the pubkey in consecutive calls' do
        e1 = nil; e2 = nil
        expect {
          e1 = subject.entity(pkey.public_key)
          e2 = subject.entity
        }.not_to raise_error
        e1.should eql(e2)
      end
    end
  end
end
