require 'spec_helper'

describe Salmon::MagicEnvelope do
  let(:payload) { Entities::TestEntity.new(test: 'asdf') }
  let(:pkey) { OpenSSL::PKey::RSA.generate(512) } # use small key for speedy specs
  let(:envelope) { Salmon::MagicEnvelope.new(pkey, payload).envelop }

  def sig_subj(env)
    data = Base64.urlsafe_decode64(env.at_xpath('me:data').content)
    type = env.at_xpath('me:data')['type']
    enc = env.at_xpath('me:encoding').content
    alg = env.at_xpath('me:alg').content

    subj = [data, type, enc, alg].map { |i| Base64.urlsafe_encode64(i) }.join('.')
  end

  def re_sign(env, key)
    new_sig = Base64.urlsafe_encode64(
              key.sign(OpenSSL::Digest::SHA256.new, sig_subj(env)))
    env.at_xpath('me:sig').content = new_sig
  end

  context 'sanity' do
    it 'constructs an instance' do
      expect { Salmon::MagicEnvelope.new(pkey, payload) }.not_to raise_error
    end

    it 'raises an error if the param types are wrong' do
      ['asdf', 1234, :test, false].each do |val|
        expect {
          Salmon::MagicEnvelope.new(val, val)
        }.to raise_error
      end
    end
  end

  context '#envelop' do
    subject { Salmon::MagicEnvelope.new(pkey, payload) }

    its(:envelop) { should be_an_instance_of Nokogiri::XML::Element }

    it 'returns a magic envelope of correct structure' do
      env = subject.envelop
      env.name.should eql('env')

      control = ['data', 'encoding', 'alg', 'sig']
      env.children.each do |node|
        control.should include(node.name)
        control.reject! { |i| i == node.name }
      end

      control.should be_empty
    end

    it 'signs the payload correctly' do
      env = subject.envelop

      subj = sig_subj(env)
      sig = Base64.urlsafe_decode64(env.at_xpath('me:sig').content)

      pkey.public_key.verify(OpenSSL::Digest::SHA256.new, sig, subj).should be_true
    end
  end

  context '#encrypt!' do
    subject { Salmon::MagicEnvelope.new(pkey, payload) }

    it 'encrypts the payload, returning cipher params' do
      params = {}
      expect {
        params = subject.encrypt!
      }.not_to raise_error
      params.should include(:key, :iv)
    end

    it 'actually encrypts the payload' do
      plain_payload = subject.payload
      params = subject.encrypt!
      encrypted_payload = subject.payload

      cipher = OpenSSL::Cipher.new(Salmon::AES_CIPHER)
      cipher.encrypt
      cipher.iv = Base64.decode64(params[:iv])
      cipher.key = Base64.decode64(params[:key])

      ciphertext = cipher.update(plain_payload) + cipher.final

      Base64.strict_encode64(ciphertext).should eql(encrypted_payload)
    end
  end

  context '::unenvelop' do
    context 'sanity' do
      it 'works with sane input' do
        expect {
          Salmon::MagicEnvelope.unenvelop(envelope, pkey.public_key)
        }.not_to raise_error
      end

      it 'raises an error if the param types are wrong' do
        ['asdf', 1234, :test, false].each do |val|
          expect {
            Salmon::MagicEnvelope.unenvelop(val, val)
          }.to raise_error
        end
      end

      it 'verifies the envelope structure' do
        expect {
          Salmon::MagicEnvelope.unenvelop(Nokogiri::XML::Document.parse('<asdf/>').root, pkey.public_key)
        }.to raise_error Salmon::MagicEnvelope::InvalidEnvelope
      end

      it 'verifies the signature' do
        other_key = OpenSSL::PKey::RSA.generate(512)
        expect {
          Salmon::MagicEnvelope.unenvelop(envelope, other_key.public_key)
        }.to raise_error Salmon::MagicEnvelope::InvalidSignature
      end

      it 'verifies the encoding' do
        bad_env = Salmon::MagicEnvelope.new(pkey, payload).envelop
        elem = bad_env.at_xpath('me:encoding')
        elem.content = 'invalid_enc'
        re_sign(bad_env, pkey)
        expect {
          e = Salmon::MagicEnvelope.unenvelop(bad_env, pkey.public_key)
        }.to raise_error Salmon::MagicEnvelope::InvalidEncoding
      end

      it 'verifies the algorithm' do
        bad_env = Salmon::MagicEnvelope.new(pkey, payload).envelop
        elem = bad_env.at_xpath('me:alg')
        elem.content = 'invalid_alg'
        re_sign(bad_env, pkey)
        expect {
          e = Salmon::MagicEnvelope.unenvelop(bad_env, pkey.public_key)
        }.to raise_error Salmon::MagicEnvelope::InvalidAlgorithm
      end
    end

    it 'returns the original entity' do
      e = Salmon::MagicEnvelope.unenvelop(envelope, pkey.public_key)
      e.should be_an_instance_of Entities::TestEntity
      e.test.should eql('asdf')
    end

    it 'decrypts on the fly, when cipher params are present' do
      env = Salmon::MagicEnvelope.new(pkey, payload)
      params = env.encrypt!

      envelope = env.envelop

      e = Salmon::MagicEnvelope.unenvelop(envelope, pkey.public_key, params)
      e.should be_an_instance_of Entities::TestEntity
      e.test.should eql('asdf')
    end
  end
end
