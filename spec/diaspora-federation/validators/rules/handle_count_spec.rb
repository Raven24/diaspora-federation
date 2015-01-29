require 'spec_helper'

describe Validation::Rule::HandleCount do
  let(:handle_str) { 3.times.map { Fabricate.sequence(:diaspora_handle) }.join(';') }

  it 'requires a parameter' do
    v = Validation::Validator.new({})
    expect do
      v.rule(:handles, :handle_count)
    end.to raise_error
  end

  it 'validates less handles' do
    v = Validation::Validator.new(OpenStruct.new(handles: handle_str))
    v.rule(:handles, handle_count: { maximum: 5 })

    expect(v).to be_valid
    expect(v.errors).to be_empty
  end

  it 'validates exactly as many handles' do
    v = Validation::Validator.new(OpenStruct.new(handles: handle_str))
    v.rule(:handles, handle_count: { maximum: 3 })

    expect(v).to be_valid
    expect(v.errors).to be_empty
  end

  it 'fails for too many handles' do
    v = Validation::Validator.new(OpenStruct.new(handles: handle_str))
    v.rule(:handles, handle_count: { maximum: 1 })

    expect(v).to_not be_valid
    expect(v.errors).to include(:handles)
  end
end
