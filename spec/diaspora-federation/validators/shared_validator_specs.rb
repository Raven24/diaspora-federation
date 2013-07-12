require 'spec_helper'

def entity_stub(entity, property, val=nil)
  s = OpenStruct.new(Fabricate.attributes_for(entity))
  s.public_send("#{property.to_s}=", val) unless val.nil?
  s
end

shared_examples 'a diaspora_handle validator' do
  it 'validates a well-formed diaspora_handle' do
    v = validator.new(entity_stub(entity, property))
    v.should be_valid
    v.errors.should be_empty
  end

  it 'must not be empty' do
    v = validator.new(entity_stub(entity, property, ''))
    v.should_not be_valid
    v.errors.should include(property)
  end

  it 'must resemble an email address' do
    v = validator.new(entity_stub(entity, property, 'i am a weird handle @@@ ### 12345'))
    v.should_not be_valid
    v.errors.should include(property)
  end
end

shared_examples 'a guid validator' do
  it 'validates a well-formed guid' do
    v = validator.new(entity_stub(entity, property))
    v.should be_valid
    v.errors.should be_empty
  end

  it 'must be at least 16 chars' do
    v = validator.new(entity_stub(entity, property, 'aaaaaa'))
    v.should_not be_valid
    v.errors.should include(property)
  end

  it 'must only contain [0-9a-f]' do
    v = validator.new(entity_stub(entity, property, 'zzz+-#*$$'))
    v.should_not be_valid
    v.errors.should include(property)
  end

  it 'must not be empty' do
    v = validator.new(entity_stub(entity, property, ''))
    v.should_not be_valid
    v.errors.should include(property)
  end
end

shared_examples 'a boolean validator' do
  it 'validates a well-formed boolean' do
    [true, 'true', false, 'false'].each do |val|
      v = validator.new(entity_stub(entity, property, val))
      v.should be_valid
      v.errors.should be_empty
    end
  end

  it 'must not be an arbitrary string or other object' do
    ['asdf', Date.today, 1234].each do |val|
      v = validator.new(entity_stub(entity, property, val))
      v.should_not be_valid
      v.errors.should include(property)
    end
  end
end
