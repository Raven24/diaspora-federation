require 'spec_helper'

shared_examples 'an Entity subclass' do
  it 'should be an Entity' do
    expect(klass).to be < Entity
  end

  it 'has its properties set' do
    expect(klass.class_prop_names).to include(*data.keys)
  end

  context 'behaviour' do
    let(:instance) { klass.new(data) }

    context '#to_h' do
      it 'should resemble the input data' do
        expect(instance.to_h).to eql(data)
      end
    end

    context '#to_xml' do
      it 'produces correct XML' do
        expect(instance.to_xml.to_s).to eql(xml.strip)
      end
    end
  end
end
