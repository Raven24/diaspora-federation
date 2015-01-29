require 'spec_helper'

module Entities
  class EntityTest < Entity
    define_props do
      property :test1
      property :test2
      property :test3, default: true
      property :test4, default: -> { true }
    end
  end
end

describe Entity do
  let(:data) { { test1: 'asdf', test2: 1234, test3: false, test4: false } }

  specify { expect(Entities::EntityTest).to be < Entity }

  it 'sets the properties on the class' do
    expect(Entities::EntityTest.class_prop_names).to include(:test1, :test2, :test3)
  end

  it 'sets property values on initialization' do
    t = Entities::EntityTest.new(data)
    expect(t.to_h).to eql(data)
  end

  it 'freezes the instance after initialization' do
    t = Entities::EntityTest.new(data)
    expect(t).to be_frozen
  end

  it 'checks for required properties' do
    expect do
      Entities::EntityTest.new({})
    end.to raise_error ArgumentError, 'missing required properties: test1, test2'
  end

  it 'sets the defaults' do
    t = Entities::EntityTest.new(test1: 1, test2: 2)
    expect(t.to_h[:test3]).to eq(true)
  end

  it 'handles callable defaults' do
    t = Entities::EntityTest.new(test1: 1, test2: 2)
    expect(t.to_h[:test4]).to eq(true)
  end

  it 'uses provided values over defaults' do
    t = Entities::EntityTest.new(data)
    expect(t.to_h[:test3]).to eq(false)
  end

  context '#to_h' do
    it 'returns a hash of the internal data' do
      t = Entities::EntityTest.new(data)
      expect(t.to_h).to include(:test1, :test2, :test3)
    end
  end

  context '#to_xml' do
    it 'returns an Nokogiri::XML::Element' do
      t = Entities::EntityTest.new(data)
      expect(t.to_xml).to be_an_instance_of Nokogiri::XML::Element
    end

    it 'has the root node named after the class (underscored)' do
      t = Entities::EntityTest.new(data)
      expect(t.to_xml.name).to eql('entity_test')
    end

    it 'contains nodes for each of the properties' do
      t = Entities::EntityTest.new(data)
      t.to_xml.children.each do |node|
        expect(%w(test1 test2 test3 test4)).to include(node.name)
      end
    end
  end

  context '::entity_name' do
    it 'strips the module and returns the name underscored' do
      expect(Entities::EntityTest.entity_name).to eql('entity_test')
      expect(Entities::TestNestedEntity.entity_name).to eql('test_nested_entity')
      expect(Entities::OtherEntity.entity_name).to eql('other_entity')
    end
  end

  context '::nested_class_props' do
    it 'returns the definition of nested class properties in an array' do
      n_props = Entities::TestNestedEntity.nested_class_props
      expect(n_props.map { |p| p[:name] }).to include(:test, :multi)
      expect(n_props.map { |p| p[:type] }).to include(Entities::TestEntity, [Entities::OtherEntity])
    end
  end

  context '::class_prop_names' do
    it 'returns the names of all class props in an array' do
      expect(Entities::EntityTest.class_prop_names).to be_an_instance_of(Array)
      expect(Entities::EntityTest.class_prop_names).to include(:test1, :test2, :test3)
    end
  end

  context 'nested entities' do
    module Entities
      class NestedTest < Entity
        define_props do
          property :asdf
          property :qwer
          entity :other, Entities::EntityTest
          entity :many, [Entities::EntityTest]
        end
      end
    end

    let(:nested_data) do
      { asdf: 'FDSA',
        qwer: 'REWQ',
        other: Entities::EntityTest.new(data),
        many: [Entities::EntityTest.new(data), Entities::EntityTest.new(data)] }
    end

    it 'gets included in the properties' do
      expect(Entities::NestedTest.class_prop_names).to include(:other, :many)
    end

    it 'gets returned by #to_h' do
      e = Entities::NestedTest.new(nested_data)
      expect(e.to_h).to eql(nested_data)
    end

    it 'gets xml-ified by #to_xml' do
      e = Entities::NestedTest.new(nested_data)
      xml = e.to_xml
      xml.children.each do |n|
        expect(%w(asdf qwer entity_test)).to include(n.name)
      end
      expect(xml.xpath('entity_test').length).to eq(3)
    end
  end
end
