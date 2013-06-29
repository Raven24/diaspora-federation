require 'spec_helper'

describe Validation::Rule::Birthday do

  let(:date_obj) { Date.new }
  let(:date_str) { '2013-06-28' }

  it 'will not accept parameters' do
    v = Validation::Validator.new({})
    expect {
      v.rule(:birthday, birthday: { param: true })
    }.to raise_error
  end

  it 'validates a date object' do
    v = Validation::Validator.new(OpenStruct.new(birthday: date_obj))
    v.rule(:birthday, :birthday)

    v.should be_valid
    v.errors.should be_empty
  end

  it 'validates a string' do
    v = Validation::Validator.new(OpenStruct.new(birthday: date_str))
    v.rule(:birthday, :birthday)

    v.should be_valid
    v.errors.should be_empty
  end

  it 'validates an empty string' do
    v = Validation::Validator.new(OpenStruct.new(birthday: ''))
    v.rule(:birthday, :birthday)

    v.should be_valid
    v.errors.should be_empty
  end

  it 'validates nil' do
    v = Validation::Validator.new(OpenStruct.new(birthday: nil))
    v.rule(:birthday, :birthday)

    v.should be_valid
    v.errors.should be_empty
  end

  it 'fails for invalid date string' do
    v = Validation::Validator.new(OpenStruct.new(birthday: "i'm no date"))
    v.rule(:birthday, :birthday)

    v.should_not be_valid
    v.errors.should include(:birthday)
  end
end
