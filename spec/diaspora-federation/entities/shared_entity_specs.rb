require 'spec_helper'

shared_examples 'an Entity subclass' do
  it 'should be an Entity' do
    klass.should be < Entity
  end

  it 'has its properties set' do
    klass.class_prop_names.should include(*data.keys)
  end

  context 'behaviour' do
    let(:instance) { klass.new(data) }

    context '#to_h' do
      it 'should resemble the input data' do
        instance.to_h.should eql(data)
      end
    end

    context '#to_xml' do
      it 'produces correct XML' do
        instance.to_xml.to_s.should eql(xml.strip)
      end
    end
  end
end
