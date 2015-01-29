require 'spec_helper'

describe Validation::Rule::Birthday do
  let(:date_obj) { Date.new }
  let(:date_str) { '2013-06-28' }

  it 'will not accept parameters' do
    v = Validation::Validator.new({})
    expect do
      v.rule(:birthday, birthday: { param: true })
    end.to raise_error
  end

  it 'validates a date object' do
    v = Validation::Validator.new(OpenStruct.new(birthday: date_obj))
    v.rule(:birthday, :birthday)

    expect(v).to be_valid
    expect(v.errors).to be_empty
  end

  it 'validates a string' do
    v = Validation::Validator.new(OpenStruct.new(birthday: date_str))
    v.rule(:birthday, :birthday)

    expect(v).to be_valid
    expect(v.errors).to be_empty
  end

  it 'validates an empty string' do
    v = Validation::Validator.new(OpenStruct.new(birthday: ''))
    v.rule(:birthday, :birthday)

    expect(v).to be_valid
    expect(v.errors).to be_empty
  end

  it 'validates nil' do
    v = Validation::Validator.new(OpenStruct.new(birthday: nil))
    v.rule(:birthday, :birthday)

    expect(v).to be_valid
    expect(v.errors).to be_empty
  end

  it 'fails for invalid date string' do
    v = Validation::Validator.new(OpenStruct.new(birthday: "i'm no date"))
    v.rule(:birthday, :birthday)

    expect(v).to_not be_valid
    expect(v.errors).to include(:birthday)
  end
end
