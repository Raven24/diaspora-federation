require 'spec_helper'

class TestEntity < Entity
end

describe PropertiesDSL do
  context 'new instance' do
    it 'takes a block' do
      PropertiesDSL.new { 'i am a block' }
    end
  end

  context 'dsl' do
    it 'returns a frozen Array' do
      i = PropertiesDSL.new { property :test }
      p = i.properties
      expect(p).to be_an_instance_of(Array)
      expect(p).to be_frozen
    end

    context 'simple properties' do
      it 'can name simple properties by symbol' do
        i = PropertiesDSL.new do
          property :test
        end
        p = i.properties
        expect(p.length).to eq(1)
        expect(p.first[:name]).to eql(:test)
        expect(p.first[:type]).to eql(String)
      end

      it 'can name simple properties by string' do
        i = PropertiesDSL.new do
          property 'test'
        end
        p = i.properties
        expect(p.length).to eq(1)
        expect(p.first[:name]).to eql('test')
        expect(p.first[:type]).to eql(String)
      end

      it 'will not accept other types for names' do
        [1234, true, {}].each do |val|
          expect do
            PropertiesDSL.new do
              property val
            end
          end.to raise_error PropertiesDSL::InvalidName
        end
      end

      it 'can define multiple properties' do
        i = PropertiesDSL.new do
          property :test
          property :asdf
          property :zzzz
        end
        p = i.properties
        expect(p.length).to eq(3)
        expect(p.map { |e| e[:name] }).to include(:test, :asdf, :zzzz)
        p.map { |e| expect(e[:type]).to eql(String) }
      end

      it 'can accept default values' do
        i = PropertiesDSL.new do
          property :test, default: :foobar
        end
        d = i.defaults
        expect(d[:test]).to eq(:foobar)
      end
    end

    context 'nested entities' do
      it 'can define nested entities' do
        i = PropertiesDSL.new do
          entity :other, TestEntity
        end
        p = i.properties
        expect(p.length).to eq(1)
        expect(p.first[:name]).to eql(:other)
        expect(p.first[:type]).to eql(TestEntity)
      end

      it 'can define an array of a nested entity' do
        i = PropertiesDSL.new do
          entity :other, [TestEntity]
        end
        p = i.properties
        expect(p.length).to eq(1)
        expect(p.first[:name]).to eql(:other)
        expect(p.first[:type]).to be_an_instance_of(Array)
        expect(p.first[:type].first).to eql(TestEntity)
      end

      it 'must be an entity subclass' do
        [1234, true, {}].each do |val|
          expect do
            PropertiesDSL.new do
              entity :fail, val
            end
          end.to raise_error PropertiesDSL::InvalidType
        end
      end

      it 'must be an entity subclass for array' do
        [1234, true, {}].each do |val|
          expect do
            PropertiesDSL.new do
              entity :fail, [val]
            end
          end.to raise_error PropertiesDSL::InvalidType
        end
      end
    end
  end
end
