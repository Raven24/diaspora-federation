require 'spec_helper'

describe Validation::Rule::TagCount do
  let(:tag_str) { '#i #love #tags' }

  it 'requires a parameter' do
    v = Validation::Validator.new({})
    expect {
      v.rule(:tags, :tag_count)
    }.to raise_error
  end

  it 'validates less tags' do
    v = Validation::Validator.new(OpenStruct.new(tags: tag_str))
    v.rule(:tags, tag_count: { maximum: 5 })

    v.should be_valid
    v.errors.should be_empty
  end

  it 'validates exactly as many tags' do
    v = Validation::Validator.new(OpenStruct.new(tags: tag_str))
    v.rule(:tags, tag_count: { maximum: 3 })

    v.should be_valid
    v.errors.should be_empty
  end

  it 'fails for too many tags' do
    v = Validation::Validator.new(OpenStruct.new(tags: tag_str))
    v.rule(:tags, tag_count: { maximum: 1 })

    v.should_not be_valid
    v.errors.should include(:tags)
  end
end
