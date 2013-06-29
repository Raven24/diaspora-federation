require 'spec_helper'

describe Validation::Rule::Numeric do

  it 'will not accept parameters' do
    v = Validation::Validator.new({})
    expect {
      v.rule(:number, numeric: { param: true })
    }.to raise_error
  end

  context 'validation' do
    it 'validates a float' do
      v = Validation::Validator.new(OpenStruct.new(number: '123.34'))
      v.rule(:number, :numeric)

      v.should be_valid
      v.errors.should be_empty
    end

    it 'validates an integer' do
      v = Validation::Validator.new(OpenStruct.new(number: '123'))
      v.rule(:number, :numeric)

      v.should be_valid
      v.errors.should be_empty
    end

    it 'validates negative numbers' do
      v = Validation::Validator.new(OpenStruct.new(number: '-987'))
      v.rule(:number, :numeric)

      v.should be_valid
      v.errors.should be_empty
    end
  end

  it 'fails for a non-numeric string' do
    v = Validation::Validator.new(OpenStruct.new(number: 'asdf qwer'))
    v.rule(:number, :numeric)

    v.should_not be_valid
    v.errors.should include(:number)
  end
end
