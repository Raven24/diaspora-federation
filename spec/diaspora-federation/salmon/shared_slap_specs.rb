require 'spec_helper'

shared_examples 'a Slap instance' do
  it { expect(subject.author_id).to eq author_id }

  context '#entity' do
    it 'requires the pubkey for the first time (to verify the signature)' do
      expect { subject.entity }.to raise_error
    end

    it 'works when the pubkey is given' do
      expect do
        subject.entity(pkey.public_key)
      end.not_to raise_error
    end

    it 'returns the entity' do
      e = subject.entity(pkey.public_key)
      expect(e).to be_an_instance_of Entities::TestEntity
      expect(e.test).to eql('qwertzuiop')
    end

    it 'does not require the pubkey in consecutive calls' do
      e1 = e2 = nil
      expect do
        e1 = subject.entity(pkey.public_key)
        e2 = subject.entity
      end.not_to raise_error
      expect(e1).to eql(e2)
    end
  end
end
