require 'spec_helper'

describe Validation::Rule::HandleCount do
  let(:handle_str) { 3.times.map{ Fabricate.sequence(:diaspora_handle) }.join(';') }

  it 'requires a parameter' do
    v = Validation::Validator.new({})
    expect {
      v.rule(:handles, :handle_count)
    }.to raise_error
  end

  it 'validates less handles' do
    v = Validation::Validator.new(OpenStruct.new(handles: handle_str))
    v.rule(:handles, handle_count: { maximum: 5 })

    v.should be_valid
    v.errors.should be_empty
  end

  it 'validates exactly as many handles' do
    v = Validation::Validator.new(OpenStruct.new(handles: handle_str))
    v.rule(:handles, handle_count: { maximum: 3 })

    v.should be_valid
    v.errors.should be_empty
  end

  it 'fails for too many handles' do
    v = Validation::Validator.new(OpenStruct.new(handles: handle_str))
    v.rule(:handles, handle_count: { maximum: 1 })

    v.should_not be_valid
    v.errors.should include(:handles)
  end
end
