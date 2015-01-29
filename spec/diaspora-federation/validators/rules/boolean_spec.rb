require 'spec_helper'

describe Validation::Rule::Boolean do
  it 'will not accept parameters' do
    v = Validation::Validator.new({})
    expect do
      v.rule(:number, numeric: { param: true })
    end.to raise_error
  end

  context 'strings' do
    it 'validates boolean-esque strings' do
      %w(true false yes no t f y n 1 0).each do |str|
        v = Validation::Validator.new(OpenStruct.new(boolean: str))
        v.rule(:boolean, :boolean)

        expect(v).to be_valid
        expect(v.errors).to be_empty
      end
    end

    it 'fails for non-boolean-esque strings' do
      v = Validation::Validator.new(OpenStruct.new(boolean: 'asdf'))
      v.rule(:boolean, :boolean)

      expect(v).to_not be_valid
      expect(v.errors).to include(:boolean)
    end
  end

  context 'numbers' do
    it 'validates 0 and 1 to boolean' do
      [0, 1].each do |num|
        v = Validation::Validator.new(OpenStruct.new(boolean: num))
        v.rule(:boolean, :boolean)

        expect(v).to be_valid
        expect(v.errors).to be_empty
      end
    end

    it 'fails for all other numbers' do
      v = Validation::Validator.new(OpenStruct.new(boolean: 1234))
      v.rule(:boolean, :boolean)

      expect(v).to_not be_valid
      expect(v.errors).to include(:boolean)
    end
  end

  context 'boolean types' do
    it 'validates true and false' do
      [true, false].each do |bln|
        v = Validation::Validator.new(OpenStruct.new(boolean: bln))
        v.rule(:boolean, :boolean)

        expect(v).to be_valid
        expect(v.errors).to be_empty
      end
    end
  end
end
