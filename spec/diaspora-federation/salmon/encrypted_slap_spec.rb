require 'spec_helper'

describe Salmon::EncryptedSlap do
  let(:author_id) { 'user_test@diaspora.example.tld' }
  let(:pkey) { OpenSSL::PKey::RSA.generate(512) } # use small key for speedy specs
  let(:okey) { OpenSSL::PKey::RSA.generate(1024) } # use small key for speedy specs
  let(:entity) { Entities::TestEntity.new(test: 'qwertzuiop') }
  let(:slap_xml) { Salmon::EncryptedSlap.generate_xml(author_id, pkey, entity, okey.public_key) }
  let(:ns) { { 'd' => DiasporaFederation::XMLNS, 'me' => Salmon::MagicEnvelope::XMLNS } }

  context '::generate_xml' do
    context 'sanity' do
      it 'accepts correct params' do
        expect do
          Salmon::EncryptedSlap.generate_xml(author_id, pkey, entity, okey.public_key)
        end.not_to raise_error
      end

      it 'raises an error when the params are the wrong type' do
        ['asdf', 12_345, true, :symbol, entity, pkey].each do |val|
          expect { Salmon::EncryptedSlap.generate_xml(val, val, val, val) }.to raise_error
        end
      end
    end

    it 'generates valid xml' do
      doc = Nokogiri::XML::Document.parse(slap_xml)
      expect(doc.root.name).to eql('diaspora')
      expect(doc.at_xpath('d:diaspora/d:encrypted_header', ns).content).to_not be_empty
      expect(doc.xpath('d:diaspora/me:env', ns).length).to eq(1)
    end

    context 'header' do
      subject do
        doc = Nokogiri::XML::Document.parse(slap_xml)
        doc.at_xpath('d:diaspora/d:encrypted_header', ns).content
      end
      let(:cipher_header) { JSON.parse(Base64.decode64(subject)) }
      let(:header_key) do
        JSON.parse(okey.private_decrypt(Base64.decode64(cipher_header['aes_key'])))
      end

      it 'encoded the header correctly' do
        json_header = {}
        expect do
          json_header = JSON.parse(Base64.decode64(subject))
        end.not_to raise_error
        expect(json_header).to include('aes_key', 'ciphertext')
      end

      it 'encrypted the public_key encrypted header correctly' do
        key = {}
        expect do
          key = JSON.parse(okey.private_decrypt(Base64.decode64(cipher_header['aes_key'])))
        end.not_to raise_error
        expect(key).to include('key', 'iv')
      end

      it 'encrypted the aes encrypted header correctly' do
        header = ''
        expect do
          header = Salmon.aes_decrypt(cipher_header['ciphertext'],
                                      header_key['key'],
                                      header_key['iv'])
        end.not_to raise_error
        header_doc = Nokogiri::XML::Document.parse(header)
        expect(header_doc.root.name).to eql('decrypted_header')
        expect(header_doc.xpath('//iv').length).to eq(1)
        expect(header_doc.xpath('//aes_key').length).to eq(1)
        expect(header_doc.xpath('//author_id').length).to eq(1)
        expect(header_doc.at_xpath('//author_id').content).to eql(author_id)
      end
    end
  end

  context '::from_xml' do
    context 'sanity' do
      it 'accepts correct params' do
        expect { Salmon::EncryptedSlap.from_xml(slap_xml, okey) }.not_to raise_error
      end

      it 'raises an error when the params have a wrong type' do
        [12_345, false, :symbol, entity, pkey].each do |val|
          expect { Salmon::EncryptedSlap.from_xml(val, val) }.to raise_error
        end
      end

      it 'verifies the existence of "encrypted_header"' do
        faulty_xml = <<XML
<diaspora>
</diaspora>
XML
        expect do
          Salmon::EncryptedSlap.from_xml(faulty_xml, okey)
        end.to raise_error Salmon::EncryptedSlap::MissingHeader
      end

      it 'verifies the existence of a magic envelope' do
        faulty_xml = <<XML
<diaspora>
  <encrypted_header/>
</diaspora>
XML
        allow(Salmon::EncryptedSlap).to receive(:header_data) { { aes_key: '', iv: '', author_id: '' } }
        expect do
          Salmon::EncryptedSlap.from_xml(faulty_xml, okey)
        end.to raise_error Salmon::MissingMagicEnvelope
      end
    end

    context 'generated instance' do
      subject { Salmon::EncryptedSlap.from_xml(slap_xml, okey) }

      it { expect(subject.cipher_params).to_not be_nil }

      it_behaves_like 'a Slap instance'
    end
  end
end
