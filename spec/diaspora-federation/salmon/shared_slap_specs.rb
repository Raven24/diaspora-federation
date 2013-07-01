require 'spec_helper'

shared_examples 'a Slap instance' do
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
