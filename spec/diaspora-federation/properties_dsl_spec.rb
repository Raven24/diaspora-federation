require 'spec_helper'

class TestEntity < Entity
end

describe PropertiesDSL do
  context 'new instance' do
    it 'takes a block' do
      PropertiesDSL.new() { 'i am a block' }
    end
  end

  context 'dsl' do
    it 'returns a frozen Array' do
      i = PropertiesDSL.new { property :test }
      p = i.get_properties
      p.should be_an_instance_of(Array)
      p.should be_frozen
    end

    context 'simple properties' do
      it 'can name simple properties by symbol' do
        i = PropertiesDSL.new {
          property :test
        }
        p = i.get_properties
        p.should have(1).item
        p.first[:name].should eql(:test)
        p.first[:type].should eql(String)
      end

      it 'can name simple properties by string' do
        i = PropertiesDSL.new {
          property 'test'
        }
        p = i.get_properties
        p.should have(1).item
        p.first[:name].should eql('test')
        p.first[:type].should eql(String)
      end

      it 'will not accept other types for names' do
        [1234, true, {}].each do |val|
          expect {
            PropertiesDSL.new {
              property val
            }
          }.to raise_error PropertiesDSL::InvalidName
        end
      end

      it 'can define multiple properties' do
        i = PropertiesDSL.new {
          property :test
          property :asdf
          property :zzzz
        }
        p = i.get_properties
        p.should have(3).items
        p.map { |e| e[:name] }.should include(:test, :asdf, :zzzz)
        p.map { |e| e[:type].should eql(String) }
      end

      it 'can accept default values' do
        i = PropertiesDSL.new {
          property :test, default: :foobar
        }
        d = i.get_defaults
        d[:test].should == :foobar
      end
    end

    context 'nested entities' do
      it 'can define nested entities' do
        i = PropertiesDSL.new {
          entity :other, TestEntity
        }
        p = i.get_properties
        p.should have(1).item
        p.first[:name].should eql(:other)
        p.first[:type].should eql(TestEntity)
      end

      it 'can define an array of a nested entity' do
        i = PropertiesDSL.new {
          entity :other, [TestEntity]
        }
        p = i.get_properties
        p.should have(1).item
        p.first[:name].should eql(:other)
        p.first[:type].should be_an_instance_of(Array)
        p.first[:type].first.should eql(TestEntity)
      end

      it 'must be an entity subclass' do
        [1234, true, {}].each do |val|
          expect {
            PropertiesDSL.new {
              entity :fail, val
            }
          }.to raise_error PropertiesDSL::InvalidType
        end
      end

      it 'must be an entity subclass for array' do
        [1234, true, {}].each do |val|
          expect {
            PropertiesDSL.new {
              entity :fail, [val]
            }
          }.to raise_error PropertiesDSL::InvalidType
        end
      end
    end
  end
end
