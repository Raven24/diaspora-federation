require 'spec_helper'

class EntityTest < Entity
  set_allowed_props :test1, :test2, :test3
end

describe Entity do
  let(:data) { { test1: 'asdf', test2: 1234, test3: false } }

  specify { EntityTest.should be < Entity }

  it 'sets the properties on the class' do
    EntityTest.class_props.should include(:test1, :test2, :test3)
  end

  it 'sets property values on initialization' do
    t = EntityTest.new(data)
    t.to_h.should == data
  end

  it 'freezes the instance after initialization' do
    t = EntityTest.new(data)
    t.should be_frozen
  end

  context '#to_h' do
    it 'returns a hash of the internal data' do
      t = EntityTest.new({})
      t.to_h.should include(:test1, :test2, :test3)
    end
  end

  context '#to_xml' do
    it 'returns an Ox::Element' do
      t = EntityTest.new({})
      t.to_xml.should be_an_instance_of Ox::Element
    end

    it 'has the root node named after the class (underscored)' do
      t = EntityTest.new({})
      t.to_xml.name.should eql("entity_test")
    end

    it 'contains nodes for each of the properties' do
      t = EntityTest.new({})
      t.to_xml.nodes.each do |node|
        ['test1','test2','test3'].should include(node.name)
      end
    end
  end
end
