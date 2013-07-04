require 'spec_helper'

class Entities::EntityTest < Entity
  define_props do
    property :test1
    property :test2
    property :test3
  end
end

describe Entity do
  let(:data) { { test1: 'asdf', test2: 1234, test3: false } }

  specify { Entities::EntityTest.should be < Entity }

  it 'sets the properties on the class' do
    Entities::EntityTest.class_prop_names.should include(:test1, :test2, :test3)
  end

  it 'sets property values on initialization' do
    t = Entities::EntityTest.new(data)
    t.to_h.should eql(data)
  end

  it 'freezes the instance after initialization' do
    t = Entities::EntityTest.new(data)
    t.should be_frozen
  end

  context '#to_h' do
    it 'returns a hash of the internal data' do
      t = Entities::EntityTest.new({})
      t.to_h.should include(:test1, :test2, :test3)
    end
  end

  context '#to_xml' do
    it 'returns an Ox::Element' do
      t = Entities::EntityTest.new({})
      t.to_xml.should be_an_instance_of Ox::Element
    end

    it 'has the root node named after the class (underscored)' do
      t = Entities::EntityTest.new({})
      t.to_xml.name.should eql("entity_test")
    end

    it 'contains nodes for each of the properties' do
      t = Entities::EntityTest.new({})
      t.to_xml.nodes.each do |node|
        ['test1','test2','test3'].should include(node.name)
      end
    end
  end

  context 'nested entities' do
    class Entities::NestedTest < Entity
      define_props do
        property :asdf
        property :qwer
        entity :other, Entities::EntityTest
        entity :many, [Entities::EntityTest]
      end
    end

    let(:nested_data) {
      {asdf: 'FDSA',
       qwer: 'REWQ',
       other: Entities::EntityTest.new(data),
       many: [Entities::EntityTest.new(data), Entities::EntityTest.new(data)]}
    }

    it 'gets included in the properties' do
      Entities::NestedTest.class_prop_names.should include(:other, :many)
    end

    it 'gets returned by #to_h' do
      e = Entities::NestedTest.new(nested_data)
      e.to_h.should eql(nested_data)
    end

    it 'gets xml-ified by #to_xml' do
      e = Entities::NestedTest.new(nested_data)
      xml = e.to_xml
      xml.nodes.each do |n|
        ['asdf', 'qwer', 'entity_test'].should include(n.name)
      end
      xml.locate('entity_test').should have(3).items
    end
  end
end
